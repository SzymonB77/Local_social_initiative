class MemberSerializer < ActiveModel::Serializer
  attributes :id, :role, :user_id, :group_id
end
