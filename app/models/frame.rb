# frozen_string_literal: true

class Frame < ApplicationRecord
  belongs_to :board
  has_many :circles, dependent: :destroy

  validates :board, presence: true
  validates :shape, :center, presence: true

  validate :frame_not_touching_others

  private

  def frame_not_touching_others
    return if shape.blank?

    sql = Frame.send(:sanitize_sql_array, [
      "SELECT 1 FROM frames WHERE board_id = ? AND id <> ? AND (ST_Touches(shape, ?) OR ST_Intersects(shape, ?)) LIMIT 1",
      board_id, id || 0, shape, shape
    ])
    if Frame.connection.select_value(sql)
      errors.add(:shape, 'touches or intersects another frame')
    end
  end


end
