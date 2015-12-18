class User < ActiveRecord::Base
  has_many :subscriptions, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter, :google_oauth2, :github, :soundcloud, :steam]

  def email_required?
    super && provider.blank?
  end

  def reset_password_token_required?
    super && provider.blank?
    end
  def password_required?
    super && provider.blank?
  end

  def self.from_omniauth(auth, current_user)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.save!
    end
  end
end