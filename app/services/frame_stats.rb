# frozen_string_literal: true

class FrameStats
  def initialize(frame)
    @frame = frame
  end

  def call
    stats = {
      x: @frame.center&.x,
      y: @frame.center&.y,
      circles_total: 0,
      highest_circle: nil,
      lowest_circle:  nil,
      leftmost_circle: nil,
      rightmost_circle: nil
    }

    circles = @frame.circles
    stats[:circles_total] = circles.count
    return stats if stats[:circles_total].zero?

    points = circles.pluck(Arel.sql('ST_X(center)'), Arel.sql('ST_Y(center)'))

    highest = points.max_by { |_, y| y }
    lowest  = points.min_by { |_, y| y }
    right   = points.max_by { |x, _| x }
    left    = points.min_by { |x, _| x }

    stats[:highest_circle]   = { x: highest[0], y: highest[1] }
    stats[:lowest_circle]    = { x: lowest[0],  y: lowest[1]  }
    stats[:rightmost_circle] = { x: right[0],   y: right[1]   }
    stats[:leftmost_circle]  = { x: left[0],    y: left[1]    }

    stats
  end
end
