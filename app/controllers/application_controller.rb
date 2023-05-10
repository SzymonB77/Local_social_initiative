class ApplicationController < ActionController::API
  include JwtToken

  private

  def authentication(role)
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    @decoded = jwt_decode(header)
    @current_user = User.find(@decoded[:user_id])
    render json: { errors: 'Access Denied' }, status: :unauthorized unless @current_user.role == role
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :not_found
  rescue JWT::DecodeError => e
    render json: { errors: e.message }, status: :unauthorized
  end

  def authenticate_admin
    authentication('admin')
  end

  def authenticate_user
    authentication('user')
  end

  def authenticate_user_or_admin
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = jwt_decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :not_found
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def it_current_user?
    if @user.id != @current_user.id && @current_user.role != 'admin'
      render json: { errors: 'You are not authorized to access this resource' }, status: :unauthorized
    end
  end
end
