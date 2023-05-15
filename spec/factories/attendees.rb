FactoryBot.define do
  factory :attendee do
    user
    event

    trait :host do
      role { 'host' }
    end
  end
end
