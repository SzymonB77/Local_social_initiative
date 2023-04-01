# == Schema Information
#
# Table name: groups
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  avatar      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :avatar
end
