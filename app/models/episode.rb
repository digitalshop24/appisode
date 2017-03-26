class Episode < ActiveRecord::Base
  belongs_to :season
  has_one :show, through: :season
  after_save :check_season_episode_number

  def days_left
    (air_date - Date.today).to_i if air_date.present?
  end


  def hours_left
    return unless air_date.present?
    air = air_stamp || (air_date.end_of_day if air_date) || Time.now
    ((air - Time.now) / 1.hour).round
  end

  def last_in_season?
    number == season.number_of_episodes
  end

  def first?
    number == 1
  end

  private
  def check_season_episode_number
    if season
      number_of_episodes = season.episodes.reorder(number: :desc).limit(1).first.number
      season.update(number_of_episodes: number_of_episodes)
    end
  end
end
