require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:regular_user)
    @admin = users(:admin_user)
    @other_user = users(:another_user)
  end

  test "should redirect unauthorized user from edit" do
    sign_in @other_user
    get edit_user_path(@user)
    assert_redirected_to users_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should allow owner to edit" do
    sign_in @user
    get edit_user_path(@user)
    assert_response :success
  end

  test "should allow admin to edit any user" do
    sign_in @admin
    get edit_user_path(@user)
    assert_response :success
  end

  test "should redirect non-admin from index" do
    sign_in @user
    get users_path
    assert_redirected_to user_path(@user)
    assert_equal "You are not authorized to view this page.", flash[:alert]
  end

  test "should allow admin to access index" do
    sign_in @admin
    get users_path
    assert_response :success
  end
end