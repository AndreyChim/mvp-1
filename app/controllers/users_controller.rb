class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:show, :edit, :update]
  skip_before_action :verify_authenticity_token, only: [:update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    if current_user.admin?
      # @users = User.all
      @users = policy_scope(User)
    else
      skip_policy_scope
      redirect_to user_path(current_user), alert: "You are not authorized to view this page."
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

   private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    unless current_user.admin? || @user == current_user
      redirect_to users_path, alert: "You are not authorized to perform this action."
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end
end
