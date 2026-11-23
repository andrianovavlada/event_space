# Справочник городов для карточек и поиска площадок.
class City < ApplicationRecord
  has_many :venues

  validates :name, presence: true, uniqueness: true
end
