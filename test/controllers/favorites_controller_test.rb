require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  test "saves from the filtered catalog, opens the venue and removes it from favorites" do
    venue = Venue.create!(name: "Зал для встречи", capacity: 40)
    catalog = venues_url(guests: 40)
    post login_path, params: { email: users(:one).email, password: "Password123" }

    get catalog
    assert_select "form[action=?] button[aria-pressed=false]", venue_favorite_path(venue)

    assert_difference("Favorite.count", 1) do
      post venue_favorite_path(venue), headers: { "Referer" => catalog }
    end
    assert_response :see_other
    assert_redirected_to catalog
    follow_redirect!
    assert_select "form[action=?] button[aria-pressed=true]", venue_favorite_path(venue)

    assert_no_difference("Favorite.count") do
      post venue_favorite_path(venue)
    end

    get favorites_path
    assert_select ".venue-catalog-link[href=?]", venue_path(venue)
    get venue_path(venue)
    assert_select ".venue-cover button[aria-pressed=true]"

    assert_difference("Favorite.count", -1) do
      delete venue_favorite_path(venue), headers: { "Referer" => favorites_url }
    end
    assert_redirected_to favorites_url
    follow_redirect!
    assert_select ".venue-catalog-link", count: 0
  end

  test "only signed-in users can change their own favorites" do
    venue = Venue.create!(name: "Чужая площадка")
    favorite = users(:two).favorites.create!(venue: venue)

    get favorites_path
    assert_redirected_to login_path
    assert_no_difference("Favorite.count") do
      post venue_favorite_path(venue)
    end
    assert_redirected_to login_path

    post login_path, params: { email: users(:one).email, password: "Password123" }
    get favorites_path
    assert_select ".venue-catalog-link", count: 0
    delete venue_favorite_path(venue)
    assert Favorite.exists?(favorite.id)
  end
end
