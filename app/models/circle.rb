# frozen_string_literal: true

class Circle < ApplicationRecord
  belongs_to :frame

  validates :radius, numericality: { greater_than: 0 }
  validates :center, presence: true

  validate :circle_fits_inside_frame
  validate :circle_not_overlapping_others, if: -> { frame.present? }

  private

  # Ensure the buffered circle is fully covered by the frame polygon.
  def circle_fits_inside_frame
    return if frame.blank? || center.blank? || radius.blank?

    # PostGIS check: frame covers the buffer around the center (our circle)
    covers = Circle.connection.select_value(
      Circle.send(:sanitize_sql_array, [
        "SELECT ST_Covers(?, ST_Buffer(?, ?))",
        frame.shape, center, radius
      ])
    )
    errors.add(:base, 'Circle must fit inside its frame') unless covers
  end

  # Ensure this circle does not overlap or touch other circles in the same frame.
  def circle_not_overlapping_others
    existing = frame.circles.where.not(id: id)
    existing.each do |other|
      distance = center.distance(other.center)
      if distance <= radius + other.radius
        errors.add(:base, 'Circle overlaps or touches another circle in the frame')
        break
      end
    end
  end

  def area
    @area ||= Math::PI * radius**2
  end

  def circumference
    @circumference ||= 2 * Math::PI * radius
  end

  def diameter
    @diameter ||= 2 * radius
  end
end
