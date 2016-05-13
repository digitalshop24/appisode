class User < ActiveRecord::Base
  has_many :subscriptions, dependent: :destroy
  has_many :devices, dependent: :destroy

  before_save :ensure_auth_token

  def ensure_auth_token
    self.auth_token ||= generate_auth_token
  end

  private
  def generate_auth_token
    loop do
      token = SecureRandom.urlsafe_base64(20)
      break token if User.where(auth_token: token).empty?
    end
  end

end
