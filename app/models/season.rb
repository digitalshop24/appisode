class Season < ActiveRecord::Base
  belongs_to :show
  has_many :episodes
  has_one :next_episode, -> { where('episodes.air_date > ?', Time.now).order(air_date: :asc) }, class_name: "Episode"
  after_save :check_show_season_number

  def create_or_update_episode episode
    new_episode = episodes.find_or_create_by(tmdb_id: episode['id'])
    new_episode.update(
      air_date: (Date.parse(episode["air_date"]) if episode["air_date"]),
      number: episode['episode_number']
    )
    new_episode
  end

  private
  def check_show_season_number
    if show
      number_of_seasons = show.seasons.order(number: :desc).limit(1).first.number
      show.update(number_of_seasons: number_of_seasons)
    end
  end
end
