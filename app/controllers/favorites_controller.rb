class FavoritesController < ApplicationController
  before_action :require_login

  def index
    @venues = current_user.favorite_venues.includes(:city).order("favorites.created_at DESC", :id)
  end

  def create
    venue = Venue.find(params[:venue_id])
    # Уникальный индекс защищает список от повторного добавления.
    current_user.favorites.create_or_find_by!(venue: venue)
    redirect_back_or_to venue_path(venue), allow_other_host: false, status: :see_other
  end

  def destroy
    venue = Venue.find(params[:venue_id])
    current_user.favorites.where(venue: venue).delete_all
    redirect_back_or_to venue_path(venue), allow_other_host: false, status: :see_other
  end

  private

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Войдите, чтобы сохранять площадки в избранном.", status: :see_other
  end
end
