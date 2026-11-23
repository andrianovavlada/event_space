require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "ranks the top three venues by average rating and then review count" do
    first = Venue.create!(name: "Янтарный зал")
    second = Venue.create!(name: "Актовый зал")
    third = Venue.create!(name: "Третья площадка")
    fourth = Venue.create!(name: "Четвёртая площадка")
    Venue.create!(name: "Без отзывов")

    { first => [ 5, 4, 5, 4 ], second => [ 5, 4 ], third => [ 5 ], fourth => [ 4 ] }.each do |venue, ratings|
      ratings.each_with_index do |rating, index|
        start_at = (index + 2).days.ago
        booking = venue.bookings.create!(user: users(:one), start_at: start_at, end_at: start_at + 1.hour, status: :completed)
        venue.reviews.create!(user: users(:one), booking: booking, rating: rating, body: "Отзыв")
      end
    end
    get root_path

    assert_response :success
    assert_select ".home-venue-card h3 a", count: 3 do |links|
      assert_equal [ third, first, second ].map(&:name), links.map(&:text)
    end
    assert_select ".home-venue-rating", text: /4,50 из 5 · Отзывы: 4/
  end

  test "shows a message instead of ranking venues without reviews" do
    get root_path

    assert_response :success
    assert_select ".home-venue-card", count: 0
    assert_select ".home-venues p", text: "Рейтинг появится, когда у площадок будут отзывы с оценками."
  end
end
