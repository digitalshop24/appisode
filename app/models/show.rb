require 'open-uri'
class Show < ActiveRecord::Base
  searchkick word_start: [:name_original, :name_ru, :name_en]
  acts_as_taggable_array_on :tags
  has_many :seasons
  has_many :subscriptions
  has_many :episodes, -> { reorder(air_date: :asc, number: :asc) }, through: :seasons
  has_many :upcoming_episodes, -> { where('episodes.air_date > ?', Time.now).order(air_date: :asc) }, through: :seasons, class_name: "Episode", source: :episodes
  has_one :current_season, -> { joins(:episodes).select('seasons.*').where('episodes.air_date > ?', Time.now).order(number: :asc) }, class_name: "Season"
  has_one :last_season, -> { order(number: :desc) }, class_name: "Season"
  has_one :next_episode, through: :current_season

  scope :airing, -> { where('shows.status = ? AND episodes.air_date > ?', 'airing', Date.today).
                      joins("LEFT OUTER JOIN seasons ON shows.id = seasons.show_id LEFT OUTER JOIN episodes ON episodes.season_id = seasons.id").
                      distinct }
  scope :popular, -> { airing.order(popularity: :asc) }
  scope :new_shows, -> { popular.where('number_of_seasons < ?', 3) }
  enum status: { airing: 'airing', hiatus: 'hiatus', closed: 'closed' }

  def self.get_user_subs user
    joins("LEFT OUTER JOIN subscriptions ON subscriptions.show_id = shows.id AND subscriptions.user_id = #{user.id}").
      select('shows.*, subscriptions.id as subscription_id')
  end

  def name lang = :original
    self["name_#{lang}".to_sym] || self[:name_en] || self[:name_original]
    # self["name_#{lang}".to_sym] || self[:name_ru] || self[:name_original]
  end

  def self.name_fields lang = nil
    res = lang && column_names.include?("name_#{lang}") ? ["name_#{lang}".to_sym] : []
    res + [:name_original, :name_en]
  end

  def tags_field= string
    self.tags = string.split(',')
  end

  def tags_field
    tags.join(',')
  end

  def self.get_json(path, params = {})
    api_key = '15e545fda3d4598527fac7245a459571'
    url = 'http://api.themoviedb.org/3/tv'
    get_params = params
    get_params[:api_key] = api_key
    uri = URI.escape("#{url}/#{path}?#{get_params.to_query}")
    tries = 0
    begin
      resp = open(uri).read
    rescue => error
      puts("ERROR ===>> #{error.class} and #{error.message}")
      sleep(2)
      tries += 1
      retry if tries < 5
    end
    JSON.parse(resp) if resp
  end

  def self.load tmdb_id
    show = get_json(tmdb_id, { language: 'ru' })
    new_show = create_or_update(show)
    show['seasons'].each do |season|
      new_season = new_show.create_or_update_season(season)
      season = get_json("#{new_show.tmdb_id}/season/#{new_season.number}", { language: 'ru' })
      if season
        season['episodes'].each do |episode|
          new_episode = new_season.create_or_update_episode(episode)
        end
        puts "------ #{Time.now} - season #{new_season.number} for \"#{new_show.name}\" loaded with #{season['episodes'].count} episodes"
      end
    end
    puts "--- #{Time.now} - show \"#{new_show.name}\" loaded"
  end

  def self.image_url(image, format = 'w500')
    "http://image.tmdb.org/t/p/#{format}#{image}"
  end

  def self.create_or_update show
    new_show = Show.find_or_create_by(tmdb_id: show['id'])
    new_show.update(
      name_ru: show['name'],
      name_original: show['original_name'],
      poster: Show.image_url(show['poster_path']),
      status: 'airing'
    )
    new_show
  end
  def create_or_update_season season
    new_season = seasons.find_or_create_by(tmdb_id: season['id'])
    new_season.update(
      number: season['season_number'],
      poster: Show.image_url(season['poster_path'])
    )
    new_season
  end

  def check_status
    unless closed?
      if airing?
        hiatus! if !next_episode || next_episode.first?
      elsif hiatus?
        airing! if next_episode && !next_episode.first?
      end
    end
  end

  rails_admin do
    list do
      sort_by :popularity
      field :id do
        column_width 60
      end
      field :tmdb_id do
        column_width 60
      end
      field :poster do
        column_width 110
        formatted_value do
          bindings[:view].tag(:img, src: bindings[:object].poster, width: '100')
        end
      end
      field :name_original
      field :name_en
      field :name_ru
      field :number_of_seasons do
        column_width 60
      end
      field :popularity do
        column_width 60
      end
      field :status do
        column_width 60
      end
    end
    edit do
      fields :name_original, :name_ru, :name_en, :tmdb_id, :poster, :popularity, :status
      field :tags_field
    end
  end
end
