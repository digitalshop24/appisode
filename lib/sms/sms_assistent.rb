class SmsAssistent < SmsSender
  SMS_API_PATH = 'https://userarea.sms-assistent.by/api/v1'
  def initialize
  	super
    @user = ENV['SMS_ASSISTENT_USER']
    @password = ENV['SMS_ASSISTENT_PASSWORD']
  end
  private
  def perform sms
  	url = "#{SMS_API_PATH}/send_sms/plain?user=#{@user}&password=#{@password}&recipient=#{sms.phone}&message=#{sms.message}&sender=#{@sender}"
    puts url
    u = URI.encode(url)
    Net::HTTP.get(URI(u)).to_i
  end
  def set_status sms, res
    sms.res = res
    if res > 0
      sms.status = 'ok'
      sms.info = { en: 'SMS sended', ru: 'SMS отправлено', code: 200 }
    else
      msg, msg_en, code = 'Ошибка при отправке SMS', 'Error while sending SMS', 500
      case res
      when -2
        msg += ': ошибка авторизации сервиса'
        msg_en += ': service auth error'
      when -4
        msg += ': телефон имеет неверный формат'
        msg_en += ': phone is invalid'
      end
      sms.status = 'error'
      sms.info = { en: msg_en, ru: msg, code: code }
    end
  end
end
