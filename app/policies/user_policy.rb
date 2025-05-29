class UserPolicy < ApplicationPolicy
  def update?
    return false if user.nil? 
    user == record || user.admin?
  end

  def edit?
    update?
  end

  def index?
    user.present? && user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end