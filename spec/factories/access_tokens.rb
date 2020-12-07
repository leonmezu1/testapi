FactoryBot.define do
  factory :access_token do
    sequence(:token) { |n| "token-#{n}" }
    user { FactoryBot.create(:user) }
  end
end
