

# inputs don't change much, so put it in another file
module Input
# @param args [GTK::Args]

# sources: started with twinstick sample

def handle_input # get_and_store_device_input, game_device_input
  # gets and stores all inputs into global state
  # also makes testing inputs easy
  state.in.shoot_vector ||= [0, 0]
  state.in.move_vector ||= [0, 0]
  state.in.shoot_vector = (get_shoot_vector)
  state.in.move_vector = (get_move_vector)
end


def get_move_vector
  # gets the directional vector of movement input
  # TODO: should use left_right_perc and up_down_perc, which conveniently combines wasd/arrows/analog
  # TODO: multiple controllers, see $inputs.controllers
  # TEMP: use WASD

  s = state.c.player_move_speed ||= 0.7071
  # dx = inputs.left_right_perc # handles wasd, arrows, analog sticks
  # dy = inputs.up_down_perc
  
  dx = 0
  dx += 1 if inputs.keyboard.d
  dx -= 1 if inputs.keyboard.a
  dy = 0
  dy += 1 if inputs.keyboard.w
  dy -= 1 if inputs.keyboard.s
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

  s = state.c.player_shot_speed ||= 0.7071
  dx = inputs.left_right_directional # arrows, d-pad
  dy = inputs.up_down_directional
  
  # dx = 0
  # dx += 1 if inputs.keyboard.key_down.right || inputs.keyboard.key_held.right
  # dx -= 1 if inputs.keyboard.key_down.left || inputs.keyboard.key_held.left
  # dy = 0
  # dy += 1 if inputs.keyboard.key_down.up || inputs.keyboard.key_held.up
  # dy -= 1 if inputs.keyboard.key_down.down || inputs.keyboard.key_held.down
  if dx != 0 and dy != 0
    dx *= s
    dy *= s
  end
  [dx, dy]
end


end # module

