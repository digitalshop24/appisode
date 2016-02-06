class Episode < ActiveRecord::Base
  belongs_to :season
  has_many :subscriptions
end
