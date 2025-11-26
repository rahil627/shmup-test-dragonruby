

# inputs don't change much, so put it in another file
module Input
# @param args [GTK::Args]

# sources: started with twinstick sample

def handle_input # get_and_store_device_input, game_device_input
  # gets and stores all inputs into global state
  # also makes testing inputs easy
  args.state.in.shoot_vector ||= [0, 0]
  args.state.in.move_vector ||= [0, 0]
  args.state.in.shoot_vector = (get_shoot_vector)
  args.state.in.move_vector = (get_move_vector)
end


def get_move_vector
  # gets the directional vector of movement input
  # TODO: should use left_right_perc and up_down_perc, which conveniently combines wasd/arrows/analog
  # TODO: multiple controllers, see $args.inputs.controllers
  # TEMP: use WASD

  s = args.state.c.player_move_speed ||= 0.7071
  # dx = args.inputs.left_right_perc # handles wasd, arrows, analog sticks
  # dy = args.inputs.up_down_perc
  
  dx = 0
  dx += 1 if args.inputs.keyboard.d
  dx -= 1 if args.inputs.keyboard.a
  dy = 0
  dy += 1 if args.inputs.keyboard.w
  dy -= 1 if args.inputs.keyboard.s
  if dx != 0 and dy != 0
    dx *= s
    dy *= s
  end
  [dx, dy]
  # NOTE: magically can do: dx, dy = move_directional_vector
end


def get_shoot_vector
  # gets the directional vector of shoot input
  # TEMP: use arrow keys

  s = args.state.c.player_shot_speed ||= 0.7071
  dx = args.inputs.left_right_directional # arrows, d-pad
  dy = args.inputs.up_down_directional
  
  # dx = 0
  # dx += 1 if args.inputs.keyboard.key_down.right || args.inputs.keyboard.key_held.right
  # dx -= 1 if args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_held.left
  # dy = 0
  # dy += 1 if args.inputs.keyboard.key_down.up || args.inputs.keyboard.key_held.up
  # dy -= 1 if args.inputs.keyboard.key_down.down || args.inputs.keyboard.key_held.down
  if dx != 0 and dy != 0
    dx *= s
    dy *= s
  end
  [dx, dy]
end


end # module

