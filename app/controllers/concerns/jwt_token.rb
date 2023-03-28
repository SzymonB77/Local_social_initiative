require "jwt"

module JwtToken

  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.secrets.secret_key_base. to_s

  def jwt_encode(user_id, role, exp: 7.days.from_now)
    payload = { user_id: user_id, user_role: role }
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end

end
