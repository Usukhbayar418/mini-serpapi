FactoryBot.define do
  factory :search_history do
    query { "MyString" }
    engine { "MyString" }
    api_key { "MyString" }
    results_count { 1 }
    duration_ms { 1 }
    ip { "MyString" }
    user_agent { "MyString" }
  end
end
