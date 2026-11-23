class VenuesController < ApplicationController
  def index
    @filters = search_filters
    @cities = City.order(:name)
    @venues = Venue.includes(:city).order(:name, :id)
    filter_by_city
    filter_by_guests
    filter_by_date
  end

  def show
    @venue = Venue.includes(:city).find(params[:id])
    @filters = search_filters
    @calendar_start = future_date(@filters[:date]) || Date.current
    @calendar = @venue.available_calendar(@calendar_start, @calendar_start + 29)
    @reviews = @venue.reviews.includes(:user).order(created_at: :desc)
  end

  private

  def search_filters
    params.permit(:city, :date, :guests).to_h
  end

  def filter_by_city
    return if @filters[:city].blank?

    city_id = Integer(@filters[:city], 10, exception: false)
    if @cities.any? { |city| city.id == city_id }
      @venues = @venues.where(city_id: city_id)
    else
      reject_filter("Выберите город из списка.")
    end
  end

  def filter_by_guests
    return if @filters[:guests].blank?

    guests = Integer(@filters[:guests], 10, exception: false)
    if guests && guests.between?(1, 2_147_483_647)
      @venues = @venues.where("capacity >= ?", guests)
    else
      reject_filter("Укажите целое положительное количество гостей.")
    end
  end

  def filter_by_date
    return if @filters[:date].blank?

    date = future_date(@filters[:date])
    return reject_filter("Выберите сегодняшнюю или будущую дату.") unless date

    @venues = @venues.available_on(date)
  end

  def future_date(value)
    return unless value.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    date = Date.iso8601(value)
    date if date >= Date.current
  rescue Date::Error
    nil
  end

  def reject_filter(message)
    # Сохраняем введённые значения и показываем ошибку вместо результатов.
    (@filter_errors ||= []) << message
    @venues = @venues.none
  end
end
