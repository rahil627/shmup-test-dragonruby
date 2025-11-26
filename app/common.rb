#!/usr/bin/env ruby

module Common
  # catch-all place for commonly-used stuff

  def off_screen_or_on_the_edge? e
    # if not Geometry.inside_rect?(l.rect, args.state.screen)
    e.x <= 0 - e.w || e.y <= 0 - e.h || e.x >= 1280 + e.w || e.y >= 720 + e.h
  end

  def off_screen? e
    # if not Geometry.inside_rect?(l.rect, args.state.screen)
    e.x < 0 - e.w || e.y < 0 - e.h || e.x > 1280 + e.w || e.y > 720 + e.h
  end
  
end
