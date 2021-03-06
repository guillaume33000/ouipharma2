class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  has_many :favs
  has_many :messages
  has_many :appointments
  # validates :first_name, presence: true
  # validates :last_name, presence: true

  validate :valid_rpps

  # validates :rpps, length: { is: 11 }

  # validates :pseudo, uniqueness: true
  # validates :email, presence: true, uniqueness: true
  # validates :phone_number, uniqueness: true, length: { is: 10 }
  # validates :contribution, presence: true
  # validates :first_install, presence: true
  # validates :role, presence: true
  # validates_numericality_of :rpps

  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable,
  :omniauthable, omniauth_providers: [:facebook]

  def self.find_for_facebook_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.picture = auth.info.image
      user.token = auth.credentials.token
      user.token_expiry = Time.at(auth.credentials.expires_at)
    end
  end

  def valid_rpps
    # check if rpps is 11 length and is numeric
    if not is_valid_rpps(rpps)
      errors.add(:rpps, "is not a valid rpps number")
    end
  end

  private

  def is_valid_rpps(code)
    s1 = s2 = 0
    code.to_s.reverse.chars.each_slice(2) do |odd, even|
      s1 += odd.to_i

      double = even.to_i * 2
      double -= 9 if double >= 10
      s2 += double
    end
    (s1 + s2) % 10 == 0
  end

end
