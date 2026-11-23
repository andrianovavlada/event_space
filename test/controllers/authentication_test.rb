require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "signs up and logs out" do
    get signup_path
    assert_response :success

    assert_difference("User.count") do
      post signup_path, params: { user: {
        name: "Анна",
        email: " New@Example.com ",
        password: "Password123",
        password_confirmation: "Password123",
        role: "employee"
      } }
    end
    assert_redirected_to root_path
    user = User.find_by!(email: "new@example.com")
    assert_equal user.id, session[:user_id]
    assert_predicate user, :client?
    follow_redirect!
    assert_response :success
    assert_select ".account-name", text: "Анна"
    assert_select ".account-identity small", text: "Клиент"

    delete logout_path
    assert_response :see_other
    assert_redirected_to root_path
    assert_nil session[:user_id]
  end

  test "shows validation errors on the registration form" do
    assert_no_difference("User.count") do
      post signup_path, params: { user: {
        name: "Анна",
        email: users(:one).email,
        password: "short"
      } }
    end

    assert_response 422
    assert_select ".field-error", text: "Почтовый адрес занят."
    assert_select ".field-error", text: "Пароль должен содержать хотя бы 8 символов."
    assert_select ".field-error", text: "Добавьте в пароль хотя бы одну латинскую букву и одну цифру."
    assert_select ".field-error", text: "Повторите пароль."
  end

  test "shows both registration errors in Russian even with an English locale" do
    I18n.with_locale(:en) do
      assert_no_difference("User.count") do
        post signup_path, params: { user: {
          name: "Анна",
          email: users(:one).email,
          password: "Password123",
          password_confirmation: "Password456"
        } }
      end
    end

    assert_response 422
    assert_select ".field-error", text: "Почтовый адрес занят."
    assert_select ".field-error", text: "Пароли не совпадают."
  end

  test "an existing employee can sign in and see the role" do
    employee = users(:two)
    assert_predicate employee, :employee?

    post login_path, params: { email: employee.email, password: "Password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".account-identity small", text: "Сотрудник"
  end

  test "retains email after a rejected login and accepts a valid password" do
    get login_path
    assert_response :success

    email = users(:one).email
    post login_path, params: { email: email, password: "a" * 73 }
    assert_response 422
    assert_select ".auth-card [role=alert]"
    assert_select "#email[value=?]", email
    assert_nil session[:user_id]

    post login_path, params: { email: " #{email.upcase} ", password: "Password123" }
    assert_redirected_to root_path
    assert_equal users(:one).id, session[:user_id]
  end
end
