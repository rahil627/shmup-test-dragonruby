#!/usr/bin/env ruby

module Math

  def vector_to_angle(dx, dy)
    # TODO: no inline..? :(
    # TODO: is there a proper name for this..?
    Math.atan2(dy, dx).to_degrees # NOTE: order: y,x
  end

  # def reflect_angle angle
  #   180 - angle
  # end

end
