
# decided to just have one module... no point of seperating them

module Common
  # catch-all place for commonly-used stuff

  ### ENTITY
  
  def off_screen_or_on_the_edge? e
    # if not Geometry.inside_rect?(l.rect, args.state.screen)
    e.x <= 0 - e.w || e.y <= 0 - e.h || e.x >= 1280 + e.w || e.y >= 720 + e.h
  end

  def off_screen? e
    # if not Geometry.inside_rect?(l.rect, args.state.screen)
    e.x < 0 - e.w || e.y < 0 - e.h || e.x > 1280 + e.w || e.y > 720 + e.h
  end


  
  ### module Math
  
  # TODO: see/use Geometry

  def vector_to_angle(dx, dy)
    # TODO: no inline..? :(
    # TODO: is there a proper name for this..?
    Math.atan2(dy, dx).to_degrees # NOTE: order: y,x
  end

  # def reflect_angle angle
  #   180 - angle
  # end

  

  ### module Defaults
  
  # common sane defaults for my personal games
  # just 'default_init args' on init and 'default_tick args' on tick and you're good!

  # TODO: is the attr_gtk macro only at class level? not module level?
  
  def default_pre_init
    
  end


  def default_init
    $args.gtk.set_window_size(500, 500)
    GTK.set_window_size(500, 500)
    # TODO: not working..
  end

  
  def default_post_init
    
  end


  def default_tick
    # return pause_because_unfocused? args # TODO: is there a better way to return from an outer function?
  end


  def pause_because_unfocused?
    # from the docs
    # if the keyboard doesn't have focus, and the game is in production mode, and it isn't the first tick
    # TODO: currently only good for desktop/keyboard
    if (not args.inputs.keyboard.has_focus and args.gtk.production) # and Kernel.tick_count != 0)
      # good for programming hot-reload workflow
      # saves battery too!
      args.outputs.background_color = [0, 0, 0, 125] # alpha doesn't work here because there is no other ouput, the program stops after this..!
      # TODO: a transaparent pause over the last ouput, not so simple..
      args.outputs.labels << { x: 640,
                               y: 360,
                               text: "PAWS",
                               alignment_enum: 1,
                               r: 255, g: 255, b: 255 }
      # $args.state.paused ||= true # could also return it, but the call stack is already 3 levels deep :/
      true
    # consider setting all audio volume to 0.0
    else
      # perform your regular tick function
      # $args.state.paused ||= false
      false
    end
  end

  
end




