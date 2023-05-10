FactoryBot.define do
  factory :event_tag do
    association :event
    association :tag
  end
end
