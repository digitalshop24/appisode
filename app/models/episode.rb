class Episode < ActiveRecord::Base
  belongs_to :season
  has_many :subscriptions
  after_save :check_season_episode_number

  def days_left
    (air_date - Date.today).to_i
  end

  def show
  	season.show
  end

  private
  def check_season_episode_number
    if season
      number_of_episodes = season.episodes.order(number: :desc).limit(1).first.number
      season.update(number_of_episodes: number_of_episodes)
    end
  end
end
