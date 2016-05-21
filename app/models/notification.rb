# require 'open-uri'
# require 'net/http'

class Notification < ActiveRecord::Base
  belongs_to :subscription

  def perform
    gcm = GCM.new(ENV['GCM_API_KEY'])
    registration_ids = subscription.user.devices.pluck(:token)
    options = { data: { message: message, title: "APPISODE" }, collapse_key: "updated_score"}
    # options = { notification: { body: message, title: 'Appisode', icon: 'appisode' } }
    response = gcm.send(registration_ids, options)
    JSON.parse(response[:body])['results'].map{ |a| a.first.first }.include?('message_id')
  end
end
