class Venue < ApplicationRecord
  belongs_to :city, optional: true
  has_many :availability_blocks
  has_many :reviews
  has_many :bookings
  has_many :favorites, dependent: :destroy

  validates :name, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # При равном среднем балле выше площадка с большим числом отзывов.
  def self.ranked_by_reviews
    joins(:reviews)
      .select("venues.*", "AVG(reviews.rating) AS average_rating", "COUNT(reviews.id) AS review_count")
      .group("venues.id")
      .order("average_rating DESC", "review_count DESC", :name, :id)
  end

  # Для поиска по дате достаточно хотя бы одного свободного интервала.
  def self.available_on(date)
    start_at = [ date.beginning_of_day, Time.current ].max
    end_at = (date + 1).beginning_of_day
    configured = where(availability_configured: true)
    return configured.none if start_at >= end_at

    blocks = unavailable_periods(configured.reorder(nil).select(:id), start_at, end_at).group_by(&:venue_id)
    fully_blocked = blocks.filter_map do |venue_id, periods|
      venue_id if AvailabilityBlock.free_intervals(start_at, end_at, periods).empty?
    end
    configured.where.not(id: fully_blocked)
  end

  # Загружаем занятые интервалы на весь календарь двумя запросами.
  def available_calendar(first_day, last_day)
    return {} unless availability_configured?

    blocks = self.class.unavailable_periods(id, first_day.beginning_of_day, (last_day + 1).beginning_of_day)
    now = Time.current
    (first_day..last_day).each_with_object({}) do |date, calendar|
      start_at = [ date.beginning_of_day, now ].max
      intervals = AvailabilityBlock.free_intervals(start_at, (date + 1).beginning_of_day, blocks)
      calendar[date] = intervals if intervals.any?
    end
  end

  # Занятое время складывается из закрытых интервалов и подтверждённых заявок.
  def self.unavailable_periods(venue_ids, start_at, end_at)
    blocks = AvailabilityBlock.overlapping(start_at, end_at).where(venue_id: venue_ids)
    bookings = Booking.confirmed.overlapping(start_at, end_at).where(venue_id: venue_ids)
    (blocks.to_a + bookings.to_a).sort_by(&:start_at)
  end
end
