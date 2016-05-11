class SmsSender
  def initialize
    @sender = 'APPISODE'
  end
  def send phone, message
    sms = Sms.new(phone, message)
    res = perform sms
    set_status(sms, res)
    sms
  end
end
