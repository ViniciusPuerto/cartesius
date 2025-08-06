# frozen_string_literal: true

class FrameBuilder
  attr_reader :board_id, :center_x, :center_y, :width, :height, :errors

  def initialize(board_id:, center_x:, center_y:, width:, height:)
    @board_id  = board_id
    @center_x  = center_x.to_f
    @center_y  = center_y.to_f
    @width     = width.to_f
    @height    = height.to_f
    @errors    = []
  end

  # Attempts to build and save a Frame. Returns the Frame instance, whether
  # persisted or not, so callers can inspect `frame.errors` when needed.
  def call
    validate_dimensions

    # If basic parameter validation failed, return a Frame with errors so the
    # controller can render 422 without attempting to build invalid geometry.
    if @errors.any?
      frame = Frame.new(board_id: board_id)
      @errors.each { |msg| frame.errors.add(:base, msg) }
      return frame
    end

    frame = Frame.new(board_id: board_id,
                      center: factory.point(center_x, center_y),
                      shape:  build_polygon)

    frame.save
    frame
  end

  private

  def validate_dimensions
    if width <= 0 || height <= 0
      @errors << "Width and height must be greater than zero"
    end
  end

  # Builds an RGeo polygon that represents the rectangle defined by center,
  # width and height.
  def build_polygon
    half_w = width / 2.0
    half_h = height / 2.0

    left   = center_x - half_w
    right  = center_x + half_w
    bottom = center_y - half_h
    top    = center_y + half_h

    points = [
      factory.point(left,  bottom),
      factory.point(right, bottom),
      factory.point(right, top),
      factory.point(left,  top),
      factory.point(left,  bottom) # close ring
    ]

    factory.polygon(factory.linear_ring(points))
  end

  def factory
    @factory ||= RGeo::Cartesian.simple_factory(srid: 0)
  end
end
