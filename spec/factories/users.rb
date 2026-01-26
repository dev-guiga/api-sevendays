FactoryBot.define do
  factory :user do
    transient do
      skip_address { false }
    end

    first_name { "John" }
    last_name { "Doe" }
    sequence(:username) { |n| "user#{n}" }  # gera usernames únicos
    sequence(:email) { |n| "user#{n}@example.com" }  # emails únicos
    password { "password123" }
    password_confirmation { "password123" }
    sequence(:cpf) { |n| "#{n.to_s.rjust(11, '0')}" }  # CPFs únicos
    birth_date { "1990-01-01" }
    status { "user" }

    after(:build) do |user, evaluator|
      next if evaluator.skip_address

      user.address ||= user.build_address(
        address: "123 Main St",
        city: "Anytown",
        state: "CA",
        neighborhood: "Downtown"
      )
    end

  trait :owner do
      status { "owner" }
    end

    trait :standard do
      status { "standard" }
    end
  end
end
