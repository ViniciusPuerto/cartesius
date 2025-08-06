# frozen_string_literal: true

class Board < ApplicationRecord
  has_many :frames, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
