class User < ApplicationRecord

    has_secure_password

    # Add validations

    validates :user_name, presence: true, uniqueness: true
    validates :email, presence: true
    validates :password, presence: true

end
