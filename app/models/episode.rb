class Episode < ActiveRecord::Base
  belongs_to :season
  has_many :subscriptions

  def days_left
    (air_date - Date.today).to_i
  end

  def show
  	season.show
  end
end
