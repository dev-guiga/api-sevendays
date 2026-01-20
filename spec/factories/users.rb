FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:username) { |n| "user#{n}" }  # gera usernames únicos
    sequence(:email_address) { |n| "user#{n}@example.com" }  # emails únicos
    password { "password123" }
    password_confirmation { "password123" }
    sequence(:cpf) { |n| "#{n.to_s.rjust(11, '0')}" }  # CPFs únicos
    address { "123 Main St" }
    city { "Anytown" }
    state { "CA" }
    neighborhood { "Downtown" }
    birth_date { "1990-01-01" }
    status { "user" }

  trait :owner do
      status { "owner" }
    end

    trait :standard do
      status { "standard" }
    end
  end
end
