FactoryBot.define do
  factory :budget do
    name { }
    timeperiod { create(:timeperiod) }
  end
end
