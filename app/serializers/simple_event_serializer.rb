class SimpleEventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :location, :short_description

  def short_description
    object.description ? object.description.truncate(50) : nil
  end
end
