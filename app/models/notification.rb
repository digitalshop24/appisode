class Notification < ActiveRecord::Base
  belongs_to :subscription

  def perform
    phone = subscription.user.phone
    u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{phone}&message=#{message}&sender=APPISODE")
    if Net::HTTP.get(URI(u))
      delete
    end
  end
end
