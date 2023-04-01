# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string
#  password_digest :string
#  name            :string
#  surname         :string
#  user_name       :string
#  role            :string
#  bio             :text
#  avatar          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class UserSerializer < ActiveModel::Serializer
  attributes :id, :user_name, :email, :name, :surname, :role, :bio, :avatar
end
