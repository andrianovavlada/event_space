class AvailabilityBlock < ApplicationRecord
  belongs_to :venue

  validates :start_at, :end_at, presence: true
  validates :end_at, comparison: { greater_than: :start_at }, if: -> { start_at && end_at }

  # Окончание одного интервала может совпадать с началом другого.
  scope :overlapping, ->(start_at, end_at) { where("start_at < ? AND end_at > ?", end_at, start_at) }

  # Из диапазона вычитаем закрытые интервалы, отсортированные по start_at.
  def self.free_intervals(start_at, end_at, blocks)
    intervals = []
    cursor = start_at
    blocks.each do |block|
      next if block.end_at <= cursor
      break if block.start_at >= end_at

      # Промежуток до следующего закрытия свободен.
      intervals << [ cursor, block.start_at ] if block.start_at > cursor
      cursor = block.end_at
      break if cursor >= end_at
    end
    intervals << [ cursor, end_at ] if cursor < end_at
    intervals
  end
end
