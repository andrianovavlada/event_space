class HomeController < ApplicationController
  def index
    @popular_venues = Venue.order(:name).limit(3)
  end
end
