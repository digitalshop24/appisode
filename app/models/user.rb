class PhoneValidator < ActiveModel::Validator
  def validate(record)
    phone = Phone.new(record.phone)
    record.errors[:phone] << 'Invalid phone number format' unless phone.valid?
  end
end

class User < ActiveRecord::Base
  has_many :subscriptions, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :notifications, through: :subscriptions

  before_save :ensure_auth_token

  # validates_with PhoneValidator
  validates :phone, presence: true, uniqueness: true

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
