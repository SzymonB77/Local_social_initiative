class UsersController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[show update destroy]
  before_action :authenticate_admin, only: %i[index]
  before_action :set_user, only: %i[show update destroy]
  before_action :it_current_user?, only: %i[show update destroy]

  # GET /users
  def index
    @users = User.all
    render json: @users, each_serializer: UserSerializer
  end

  # GET /users/:id
  def show
    render json: @user, serializer: UserSerializer
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, serializer: UserSerializer
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/:id
  def update
    if @user.update(user_params)
      render json: @user, serializer: UserSerializer
    else
      render json: { errors: @user.errors.messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    render json: @user if @user.destroy
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:id, :nickname, :email, :password, :name, :surname, :role, :bio, :avatar)
  end
end
