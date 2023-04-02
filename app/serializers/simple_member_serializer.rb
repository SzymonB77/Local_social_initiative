class SimpleMemberSerializer < ActiveModel::Serializer
  attributes :id, :role, :user_name, :user_surname, :user_avatar

  def user_name
    object.user.name
  end

  def user_surname
    object.user.surname
  end

  def user_avatar
    object.user.avatar
  end
end
