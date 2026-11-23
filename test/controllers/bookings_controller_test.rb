require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  test "signs in from bookings and only displays the current user's bookings" do
    venue = Venue.create!(name: "Моя площадка")
    other_venue = Venue.create!(name: "Чужая площадка")
    booking = users(:one).bookings.create!(venue: venue, start_at: 2.days.ago, end_at: 1.day.ago, status: :completed)
    users(:two).bookings.create!(venue: other_venue, start_at: 2.days.ago, end_at: 1.day.ago, status: :completed)
    booking.create_review!(user: users(:one), venue: venue, rating: 5, body: "Мой отзыв")

    get my_bookings_path, params: { user_id: users(:two).id }
    assert_redirected_to login_path
    follow_redirect!
    assert_select "[role=alert]", text: "Войдите, чтобы посмотреть свои бронирования."

    post login_path, params: { email: users(:one).email, password: "Password123" }
    assert_redirected_to my_bookings_path
    follow_redirect!
    assert_select ".booking-card", count: 1
    assert_select ".booking-card a", text: venue.name
    assert_select ".booking-status", text: "Завершено"
    assert_select ".booking-review p", text: "Мой отзыв"
  end

  test "a review requires the author's completed booking for the same venue" do
    venue = Venue.create!(name: "Зал")
    booking = users(:two).bookings.create!(venue: venue, start_at: 2.days.ago, end_at: 1.day.ago, status: :completed)
    review = venue.reviews.build(user: users(:one), rating: 5, body: "Отзыв")

    assert_not review.valid?
    assert review.errors[:booking].present?

    review.booking = booking
    assert_not review.valid?
    assert review.errors[:booking].present?
  end
end
