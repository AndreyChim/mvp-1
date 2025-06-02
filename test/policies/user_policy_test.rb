require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @admin = users(:admin_user)
    @other_user = users(:another_user)
  end

  test "owner can update their own profile" do
    assert_permit @user, @user, :update?
  end

  test "admin can update any user's profile" do
    assert_permit @admin, @user, :update?
  end

  test "non-admin cannot update another user's profile" do
    refute_permit @other_user, @user, :update?
  end

  test "guest cannot update any profile" do
    refute_permit nil, @user, :update?
  end

  test "admin can access users index" do
    assert_permit @admin, User, :index?
  end

  test "non-admin cannot access users index" do
    refute_permit @user, User, :index?
  end

  private

  def assert_permit(user, record, action)
    assert UserPolicy.new(user, record).public_send(action),
      "User #{user&.email} should be permitted to #{action} #{record}, but isn't"
  end

  def refute_permit(user, record, action)
    refute UserPolicy.new(user, record).public_send(action),
      "User #{user&.email} should NOT be permitted to #{action} #{record}, but is"
  end
end