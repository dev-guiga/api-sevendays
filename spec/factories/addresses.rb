FactoryBot.define do
  factory :address do
    address { "123 Main St" }
    city { "Anytown" }
    state { "CA" }
    neighborhood { "Downtown" }
    association :user, factory: :user, strategy: :build, skip_address: true
  end
end
