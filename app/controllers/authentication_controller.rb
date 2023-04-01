class AuthenticationController < ApplicationController
  # POST /auth/login
  def login
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      exp = Time.now + 1000.hour.to_i
      token = jwt_encode(@user.id, @user.role, exp: exp.to_i)
      render json: { username: @user.user_name, exp: exp.strftime('%d-%m-%Y %H:%M'), token: token, role: @user.role },
             status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end
end
