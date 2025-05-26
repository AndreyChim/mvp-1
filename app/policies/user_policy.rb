class UserPolicy < ApplicationPolicy
  def update?
    user == record
  end

  def edit?
    update?
  end

  # Add more actions as needed (show, destroy, etc)

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