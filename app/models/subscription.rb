class Subscription < ActiveRecord::Base
	belongs_to :user
	belongs_to :show
	belongs_to :episode
	has_many :notifications, dependent: :destroy
	enum subtype: %i(episode new_episodes season)
	after_create :create_notifications
	def create_notifications
	  if episode?
	  	episode =  Episode.find(episode_id)
	  	notifications.create(
	  		date: episode.air_date,
	  		message: "Вышла #{episode.number}-я серия сериала \"#{episode.season.show.name}\""
	  	)
	  elsif new_episodes?
	  	show.upcoming_episodes.each do |episode|
	  		notifications.create(
		  		date: episode.air_date,
		  		message: "Вышла новая #{episode.number}-я серия сериала \"#{episode.season.show.name}\""
		  	)
	  	end
	  elsif season?
	  	episode = show.upcoming_episodes.last
	  	notifications.create(
	  		date: episode.air_date,
	  		message: "Вышла последняя #{episode.number}-я серия в сезоне сериала \"#{episode.season.show.name}\""
	  	)
	  end	  		
	end
end
