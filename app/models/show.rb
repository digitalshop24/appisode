require 'open-uri'
class Show < ActiveRecord::Base
  has_many :seasons
  has_many :subscriptions
  # default_scope { order('created_at DESC') }
  def self.search(query)
    where('lower(name) like lower(:query) or lower(russian_name) like lower(:query)', { query: "%#{query}%" })
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

  def self.airing
    where('shows.in_production = ? AND episodes.air_date > ?', true, Date.today).
      joins(seasons: [:episodes]).group('shows.id')
  end

  def self.popular
    airing.order(popularity: :asc).limit(100)
  end

  def self.new_shows
    airing.having('count(seasons.id) < ?', 3).order(popularity: :asc).limit(100)
  end

  def self.create_or_update show
    new_show = Show.find_or_create_by(tmdb_id: show['id'])
    new_show.update(
      russian_name: show['name'],
      name: show['original_name'],
      poster: Show.image_url(show['poster_path']),
      in_production: show['in_production']
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
  def episodes
    ids = seasons.pluck(:id)
    Episode.where(season_id: ids)
  end
  def upcoming_episodes
    episodes.where('air_date > ?', Time.now).order(air_date: :asc)
  end
  def next_episode
    episodes.where('air_date > ?', Time.now).order(air_date: :asc).first
  end
end
