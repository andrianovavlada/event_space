require "test_helper"

class VenuesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get venues_url
    assert_response :success
  end
end
