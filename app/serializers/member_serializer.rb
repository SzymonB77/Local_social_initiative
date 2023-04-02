# == Schema Information
#
# Table name: members
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  group_id   :bigint           not null
#  role       :string           default("member")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MemberSerializer < ActiveModel::Serializer
  attributes :id, :role, :user_id, :group_id
end
