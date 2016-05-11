class Sms
  attr_accessor :status, :info, :res
  attr_reader :phone, :message
  def initialize phone, message
    @phone, @message = phone, message
  end
end