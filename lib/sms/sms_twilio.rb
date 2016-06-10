class SmsTwilio < SmsSender
  def initialize
    super
    @from = ENV['TWILIO_PHONE']
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end
  private
  def perform sms
    begin
      @client.messages.create(
        from: @from,
        to: sms.phone,
        body: sms.message
      )
      { status: 'ok' }
    rescue => error
      { status: 'error', message: error.message }
    end
  end
  def set_status sms, res
    sms.res = res
    if res[:status] == 'error'
      sms.status = 'error'
      sms.info = { en: res[:message], ru: res[:message], code: 200 }
    else
      sms.status = 'ok'
      sms.info = { en: 'SMS sended', ru: 'SMS отправлено', code: 200 }
    end
  end
end
