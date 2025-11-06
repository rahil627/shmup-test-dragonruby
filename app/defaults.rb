
module Defaults
# common sane defaults for my personal games
# just 'run_defaults args' on tick and you're good!

  
def run_defaults_pre_init args
  
end

def run_defaults_init args
    $args.gtk.set_window_size(500, 500)
    GTK.set_window_size(500, 500)
    # TODO: not working..
end

  
def run_defaults_post_init args
  pause_because_unfocused? args
end


def pause_because_unfocused? args

  # from the docs
  if (!args.inputs.keyboard.has_focus && args.gtk.production) # && Kernel.tick_count != 0)
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

def unfocused?
  # TODO: currently only good for desktop/keyboard
  # just return on production release for now
  return if args.gtk.production

  # if the keyboard doesn't have focus, and the game is in production mode, and it isn't the first tick
  (not args.inputs.keyboard.has_focus and Kernel.tick_count != 0)
end


end # module

