class Season < ActiveRecord::Base
  belongs_to :show
  has_many :episodes
  
  def create_or_update_episode episode
    new_episode = episodes.find_or_create_by(tmdb_id: episode['id'])
    new_episode.update(
      air_date: (Date.parse(episode["air_date"]) if episode["air_date"]),
      number: episode['episode_number']
    )
    new_episode
  end
end
