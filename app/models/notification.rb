# require 'open-uri'
# require 'net/http'

class Notification < ActiveRecord::Base
  belongs_to :subscription

  def perform
    # if subscription.season?
    #   season_date = subscription.show.upcoming_episodes.last.air_date
    #   if season_date != Date.today
    #     subscription.notifications.map{|n| n.update(date: season_date)}
    #     return
    #   end
    # end
    phone = subscription.user.phone
    u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{phone}&message=#{message}&sender=APPISODE")
    if Net::HTTP.get(URI(u))
      delete
    end
  end

  def self.push(token)
    push_uri = URI("https://push.ionic.io/api/v1/push")

    http = Net::HTTP.new(push_uri.host)
    request = Net::HTTP::Post.new(push_uri.request_uri)
    request.basic_auth(ENV['ionic_secret_key'], '')
    request["Content-Type"] = 'application/json'
    request["X-Ionic-Application-Id"] = ENV['ionic_app_id']
    request.body = {tokens: [token], notification: {alert: "hello world"}}.to_json
    response = http.request(request)
    JSON.parse response.body
  end
end
