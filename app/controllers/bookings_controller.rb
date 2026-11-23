class BookingsController < ApplicationController
  def index
    unless logged_in?
      session[:show_bookings_after_login] = true
      return redirect_to login_path, alert: "Войдите, чтобы посмотреть свои бронирования."
    end

    @bookings = current_user.bookings.includes(:venue, :review).order(start_at: :desc, id: :desc)
  end
end
