require "test_helper"

class VenuesControllerTest < ActionDispatch::IntegrationTest
  test "opens the catalog" do
    get venues_url
    assert_response :success
  end

  test "only shows search in the catalog and retains combined filters" do
    city = City.create!(name: "Москва")
    other_city = City.create!(name: "Тула")
    date = Date.current + 1
    matching = Venue.create!(name: "Подходящий зал", city: city, capacity: 50, availability_configured: true)
    blocked = Venue.create!(name: "Занятый зал", city: city, capacity: 100, availability_configured: true)
    blocked.availability_blocks.create!(start_at: date.beginning_of_day, end_at: (date + 2).beginning_of_day)
    Venue.create!(name: "Тесный зал", city: city, capacity: 10, availability_configured: true)
    Venue.create!(name: "Зал в другом городе", city: other_city, capacity: 100, availability_configured: true)
    Venue.create!(name: "Зал без календаря", city: city, capacity: 100)

    get root_path
    assert_response :success
    assert_select "form[action=?]", venues_path, count: 0

    get venues_path, params: { city: city.id, date: date.iso8601, guests: 50 }
    assert_response :success
    assert_select "form[action=?]", venues_path do
      assert_select "select[name=city] option[value=?]", city.id.to_s
      assert_select "input[name=date][type=date]"
      assert_select "input[name=guests][type=number]"
    end

    assert_select "#city option[selected][value=?]", city.id.to_s
    assert_select "#date[value=?]", date.iso8601
    assert_select "#guests[value='50']"
    assert_select "input[type=time]", count: 0
    assert_select "dialog", count: 0
    assert_select ".venue-catalog-link", count: 1
    details_path = venue_path(matching, city: city.id, date: date.iso8601, guests: 50)
    assert_select ".venue-catalog-link[href=?]:not([data-turbo-frame])", details_path, text: /Подходящий зал/
    assert_select ".venue-catalog-link[href=?] .venue-card-photo img[src][loading=lazy]", details_path
  end

  test "keeps the searched date in the venue calendar and excludes confirmed bookings" do
    date = Date.current + 45
    start_at = date.beginning_of_day
    end_at = (date + 1).beginning_of_day
    matching = Venue.create!(name: "Частично свободный зал", availability_configured: true)
    occupied = Venue.create!(name: "Занятый зал", availability_configured: true)
    user = users(:one)
    matching.bookings.create!(user: user, start_at: start_at, end_at: start_at + 2.hours, status: :confirmed)
    matching.bookings.create!(user: user, start_at: start_at + 2.hours, end_at: end_at, status: :cancelled)
    occupied.bookings.create!(user: user, start_at: start_at, end_at: end_at, status: :confirmed)

    get venues_path, params: { date: date.iso8601 }
    details_path = venue_path(matching, date: date.iso8601)
    assert_select ".venue-catalog-link", count: 1
    assert_select ".venue-catalog-link[href=?]", details_path

    get details_path
    assert_select ".venue-back-link[href=?]", venues_path(date: date.iso8601)
    assert_select ".venue-availability-day:has(time[datetime=?]) dd span", date.iso8601, text: "02:00–24:00"
  end

  test "matches partially available days and shows exact intervals only in the venue page" do
    date = Date.current + 1
    matching = Venue.create!(name: "Свободный зал", availability_configured: true)
    matching.availability_blocks.create!(start_at: date.beginning_of_day + 9.hours, end_at: date.beginning_of_day + 10.hours)
    matching.availability_blocks.create!(start_at: date.beginning_of_day + 12.hours, end_at: date.beginning_of_day + 14.hours)
    blocked = Venue.create!(name: "Закрытый зал", availability_configured: true)
    blocked.availability_blocks.create!(start_at: date.beginning_of_day + 11.hours, end_at: date.beginning_of_day + 13.hours)

    get venues_path, params: { date: date.iso8601 }
    assert_response :success
    assert_select ".venue-catalog-link", count: 2
    assert_select ".venue-availability", count: 0

    get venue_path(matching)
    assert_response :success
    assert_select ".venue-availability-day:has(time[datetime=?])", date.iso8601 do
      assert_select "dd span", count: 3
      assert_select "dd span", text: "00:00–09:00"
      assert_select "dd span", text: "10:00–12:00"
      assert_select "dd span", text: "14:00–24:00"
    end
  end

  test "shows a readable error for malformed search values" do
    get venues_path, params: { city: "1oops", date: "2026-02-30", guests: 0 }

    assert_response :success
    assert_select "[role=alert] p", count: 3
    assert_select "[role=alert] p", text: "Выберите город из списка."
    assert_select ".venue-catalog-link", count: 0
  end

  test "shows price, description, open dates and reviews on the full venue page" do
    today = Date.current
    venue = Venue.create!(name: "Карточка зала", description: "Зал с проектором", capacity: 50,
                          hourly_rate: 2000, availability_configured: true)
    venue.availability_blocks.create!(start_at: today.beginning_of_day, end_at: (today + 1).beginning_of_day)
    booking = venue.bookings.create!(user: users(:one), start_at: 2.days.ago, end_at: 1.day.ago, status: :completed)
    venue.reviews.create!(user: users(:one), booking: booking, rating: 5, body: "Удобная площадка")

    get venue_path(venue)
    assert_response :success
    assert_select "header.venue-cover h1", text: venue.name
    assert_select "header.venue-cover img"
    assert_select ".venue-back-link[href=?]", venues_path
    assert_select "dd", text: /2 000,00 ₽\/час/
    assert_select "dd", text: "До 50 чел."
    assert_select ".venue-details p", text: venue.description
    assert_select "time[datetime=?]", today.iso8601, count: 0
    assert_select "time[datetime=?]", (today + 1).iso8601
    assert_select ".venue-reviews strong", text: users(:one).name
    assert_select ".venue-reviews p", text: "Удобная площадка"
  end
end
