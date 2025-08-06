# frozen_string_literal: true

FactoryBot.define do
  factory :board do
    sequence(:name) { |n| "Board #{n}" }
  end
end
