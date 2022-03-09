# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "boring+generators@example.com" }
    password { "boring+generators" }
  end
end
