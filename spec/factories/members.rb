FactoryBot.define do
  factory :member do
    user
    group
    role { 'member' }

    trait :organizer do
      role { 'organizer' }
    end
  end
end
