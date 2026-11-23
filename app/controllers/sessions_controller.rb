class SessionsController < ApplicationController
  def new
  end

  def create
    @email = params[:email].to_s.strip.downcase
    user = User.find_by(email: @email)
    password = params[:password].to_s

    if password.bytesize <= ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED && user&.authenticate(password)
      destination = session[:show_bookings_after_login] ? my_bookings_path : root_path
      # После входа создаём новую сессию для вошедшего пользователя.
      reset_session
      session[:user_id] = user.id

      redirect_to destination, status: :see_other, notice: "Вы успешно вошли!"
    else
      flash.now[:alert] = "Неверный email или пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session

    redirect_to root_path, status: :see_other, notice: "Вы вышли из аккаунта"
  end
end
