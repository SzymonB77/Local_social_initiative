FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "group #{n}" }
    description { Faker::Lorem.paragraph }
    avatar { Faker::Avatar.image }

    # Definiowanie powiązań z Events
    # transient do
    #   events_count { 3 } # Liczba powiązanych wydarzeń do utworzenia
    # end

    # after(:create) do |group, evaluator|
    #   create_list(:event, evaluator.events_count, group: group)
    # end

    # after(:create) do |group, evaluator|
    #   evaluator.events_count.times do
    #     group.events ||= FactoryBot.create(:event, name: Faker::Lorem.unique.word, start_time: Faker::Time.forward(days: 23, period: :morning))
    #   end
    # end

    # Definiowanie powiązań z Members
    # transient do
    #   members_count { 4 } # Liczba powiązanych członków do utworzenia
    # end

    # after(:create) do |group, evaluator|
    #   create_list(:member, evaluator.members_count, group: group)
    # end

    # Definiowanie powiązań z Users
    after(:create) do |group|
      group.users = group.members.map(&:user)
    end
  end
end
