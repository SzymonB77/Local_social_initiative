FactoryBot.define do
  factory :attendee do
    user
    event
    # role { 'attendee' }

    trait :host do
      role { 'host' }
    end
  end
end
