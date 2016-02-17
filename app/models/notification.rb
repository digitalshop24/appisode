class Notification < ActiveRecord::Base
  belongs_to :subscription

  def perform
  	# if subscription.season?
  	# 	season_date = subscription.show.upcoming_episodes.last.air_date
  	# 	if season_date != Date.today
  	# 		subscription.notifications.map{|n| n.update(date: season_date)}
  	# 		return
  	# 	end
  	# end
    phone = subscription.user.phone
    u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{phone}&message=#{message}&sender=APPISODE")
    if Net::HTTP.get(URI(u))
      delete
    end
  end
end
