# require 'open-uri'
# require 'net/http'

class Notification < ActiveRecord::Base
  scope :not_viewed, -> { where(viewed: false).order(created_at: :desc) }
  has_one :show, through: :subscription
  belongs_to :subscription

  def perform
    gcm = GCM.new(ENV['GCM_API_KEY'])
    registration_ids = subscription.user.devices.pluck(:token)
    options = { data: { message: message, title: "APPISODE", notId: id, show_id: subscription&.show_id }}
    # options = { notification: { body: message, title: 'Appisode', icon: 'appisode' } }
    response = gcm.send(registration_ids, options)
    JSON.parse(response[:body])['results'].map{ |a| a.first.first }.include?('message_id')
  end

end
