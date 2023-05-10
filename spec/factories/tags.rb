FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.unique.word }

    # Definiowanie powiązań z Event
    transient do
      events_count { 3 } # Liczba powiązanych wydarzeń do utworzenia
    end

    # after(:create) do |tag, evaluator|
    #   create_list(:event, evaluator.events_count, tags: [tag])
    # end
    # after(:build) do |tag, evaluator|
    #   evaluator.events_count.times do
    #     tag.events ||= FactoryBot.build(:event, name: Faker::Lorem.unique.word)
    #   end
    # end

    # create_list - przyjmuje trzy argumenty: nazwę fabryki, liczbę obiektów do utworzenia oraz opcjonalne atrybuty dla każdego obiektu.
    # transient - definiuje tymczasowe atrybuty, które można przekazać do fabryki.
    # evaluator - jest specjalnym obiektem, który zawiera te tymczasowe atrybuty
    # oraz inne informacje dotyczące utworzonego obiektu.
  end
end
