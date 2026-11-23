require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires at least two characters in each email part and a letter in the address" do
    user = users(:one)

    %w[a@bb.cc aa@b.cc aa@bb.c aa@bb aa@bb.c.dd 12@34.56].each do |email|
      user.email = email
      assert_not user.valid?, "Accepted #{email}"
      assert user.errors[:email].present?
    end

    %w[ab@cd.ef 12@ab.cd ab@cd.ef.gh].each do |email|
      user.email = email
      assert user.valid?, user.errors.full_messages.to_sentence
    end
  end
end
