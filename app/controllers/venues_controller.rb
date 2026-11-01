class VenuesController < ApplicationController
  def index # страница списка площадок
    @venues = Venue.order(:name) # получение площадок из базы
  end
end
