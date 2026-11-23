class RegistrationsController < ApplicationController
  around_action :use_russian_locale

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      reset_session
      session[:user_id] = @user.id

      redirect_to root_path, status: :see_other, notice: "Регистрация успешно завершена!"
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    # Два запроса могут одновременно попытаться зарегистрировать один адрес.
    @user.errors.add(:email, :taken)
    render :new, status: :unprocessable_entity
  end

  private

  def use_russian_locale(&action)
    I18n.with_locale(:ru, &action)
  end

  def user_params
    # При самостоятельной регистрации роль определяется моделью.
    params.expect(user: [ :name, :email, :password, :password_confirmation ])
  end
end
