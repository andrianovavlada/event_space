class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :venue
  has_one :review

  enum :status, { pending: 0, confirmed: 1, cancelled: 2, completed: 3 }, default: :pending
  scope :overlapping, ->(start_at, end_at) { where("start_at < ? AND end_at > ?", end_at, start_at) }

  validates :start_at, :end_at, presence: true
  validates :end_at, comparison: { greater_than: :start_at }, if: -> { start_at && end_at }
end
