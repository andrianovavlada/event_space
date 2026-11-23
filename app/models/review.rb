# Отзыв пользователя о площадке с оценкой от 1 до 5.
class Review < ApplicationRecord
  belongs_to :venue
  belongs_to :user
  belongs_to :booking, optional: true

  validates :body, presence: true
  validates :rating, inclusion: { in: 1..5 }
  # Старые отзывы могли быть сохранены до появления бронирований.
  validates :booking, presence: true, if: -> { new_record? || booking_id_in_database.present? }
  validates :booking_id, uniqueness: true, allow_nil: true
  validate :matches_completed_booking, if: :booking

  private

  def matches_completed_booking
    return if booking.completed? && booking.end_at && booking.end_at <= Time.current &&
      booking.user_id == user_id && booking.venue_id == venue_id

    errors.add(:booking, "должно быть завершено и принадлежать автору отзыва и этой площадке")
  end
end
