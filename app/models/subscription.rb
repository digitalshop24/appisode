class Subscription < ActiveRecord::Base
	default_scope { where(active: true) }
	belongs_to :user
	belongs_to :show
	belongs_to :episode
	has_many :notifications, dependent: :destroy
	enum subtype: %i(episode new_episodes season)

  validates_uniqueness_of :user_id, scope: [:show_id]
end
