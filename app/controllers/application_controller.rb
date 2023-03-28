class ApplicationController < ActionController::API
    
    include JwtToken

    private

    def authenticate_user
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
end
