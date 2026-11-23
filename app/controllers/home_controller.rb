class HomeController < ApplicationController
  def index
    @popular_venues = Venue.ranked_by_reviews.limit(3)
  end
end
