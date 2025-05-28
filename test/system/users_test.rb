require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:regular_user)
    @admin = users(:admin_user)
    @other_user = users(:another_user)
  end

  test "unauthorized user cannot edit another user's profile" do
    sign_in @other_user
    visit edit_user_path(@user)
    assert_text "You are not authorized"
    assert_current_path root_path
  end

  test "user can edit their own profile" do
    sign_in @user
    visit edit_user_path(@user)
    assert_selector "h1", text: "Edit User"
  end

  test "admin can edit another user's profile" do
    sign_in @admin
    visit edit_user_path(@user)
    assert_selector "h1", text: "Edit User"
  end

  test "non-admin cannot access users index" do
    sign_in @user
    visit users_path
    assert_text "You are not authorized"
    assert_current_path user_path(@user)
  end

  test "admin can access users index" do
    sign_in @admin
    visit users_path
    assert_selector "h1", text: "All Users"
  end
end