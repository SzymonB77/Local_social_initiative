# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string
#  password_digest :string
#  name            :string
#  surname         :string
#  nickname        :string
#  role            :string
#  bio             :text
#  avatar          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :email, :name, :surname, :role, :bio, :avatar
end
