class Phone
  attr_reader :phone, :formatted_phone
  def initialize phone
    @phone = phone
    validate!
  end
  def valid?
    @valid
  end
  private
  def validate!
    lookup_client = Twilio::REST::LookupsClient.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    begin
      number = lookup_client.phone_numbers.get(@phone)
      @formatted_phone = number.phone_number
      @valid = true
    rescue => e
      if e.code == 20404
        @valid = false
      else
        raise e
      end
    end
  end
end