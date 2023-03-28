class UserSerializer < ActiveModel::Serializer
  attributes :id, :user_name, :email, :name, :surname, :role, :bio, :avatar
end
