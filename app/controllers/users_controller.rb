class UsersController < ApplicationController
    before_action :authenticate_user, only: %i[show]
    before_action :set_user, only: %i[show update destroy]

    def index
        @users = User.all
        render json: @users
    end

    def show
        user = User.find(params[:id])
        if user.id == @current_user.id
            render json: { user: user }
        else
            render json: { errors: "You are not authorized to view this user's profile" }, status: :unauthorized
        end
    end

    def create
        @user = User.new(user_params)
        
        if @user.save
            render json: @user, status: 201
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end

    def update
        if @user.update(user_params)
          render json: @user, serializer: UserSerializer
        else
          render json: { errors: @user.errors.messages }, status: :unprocessable_entity
        end
    end

    def destroy
        render json: @user if @user.destroy
    end

    private

    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:id, :user_name, :email, :password, :name)
    end
end
