class User < ApplicationRecord
  has_secure_password
  has_many :bookings
  has_many :favorites, dependent: :destroy
  has_many :favorite_venues, through: :favorites, source: :venue

  enum :role, { client: 0, employee: 1 }, default: :client

  before_validation :normalize_email

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 60 }

  validates :email,
            presence: true,
            length: { maximum: 254 },
            uniqueness: { case_sensitive: false }

  validate :email_format, if: -> { email.present? }

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  validates :password_confirmation, presence: true, on: :create

  validate :password_complexity, if: -> { password.present? }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def email_format
    local_part, domain = email.split("@", 2)
    domain_parts = domain.to_s.split(".", -1)

    return if URI::MailTo::EMAIL_REGEXP.match?(email) &&
              local_part.length >= 2 &&
              domain_parts.length >= 2 &&
              domain_parts.all? { |part| part.length >= 2 } &&
              email.match?(/[a-z]/)

    errors.add(:email, :invalid)
  end

  def password_complexity
    unless password.match?(/[A-Za-z]/) &&
           password.match?(/[0-9]/)
      errors.add(:password, :complexity)
    end
  end
end
