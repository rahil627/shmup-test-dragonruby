
gen'd using chromebook's notebookLM
  - i uploaded the docs and sample web-sites as it's only two sources
  - TODO: add more

just a few classics to quickly make for some practice..


* super smash bros
This is a comprehensive code framework designed to implement the core mechanics of a platform fighter similar to Super Smash Bros. in DragonRuby Game Toolkit.
This implementation utilizes concepts extracted from the sources, specifically focusing on platformer physics (gravity, jumping, acceleration, and ground collision), and entity management for basic combat structure.
Place the following Ruby code into your app/main.rb file.
# The core game structure follows the standard DragonRuby pattern:
# defaults -> input -> calc -> render

class SmashLikeGame
  attr_gtk

  # --- Constants ---
  # Physics constants derived from platformer samples [2, 3]
  GRAVITY = -1.0
  JUMP_POWER = 15.0
  ACCELERATION = 1.5
  MAX_SPEED = 8.0
  SLOWDOWN_RATE = 0.85

  # --- Core Game Loop ---
  def tick
    defaults
    input
    calc
    render
  end

  # --- 1. Initialization (Defaults) ---
  def defaults
    # Initialize Stage / Ground
    state.ground ||= { x: 0, y: 0, w: 1280, h: 60, path: :solid, r: 50, g: 50, b: 50 }

    # Initialize Player 1
    state.player_one ||= new_player(100, 60, 255, 0, 0, :one)

    # Initialize Player 2
    state.player_two ||= new_player(1180, 60, 0, 0, 255, :two)

    # Initialize Active Hitboxes (for attacks)
    state.hitboxes ||= []
  end

  # Helper method to create a new player entity
  def new_player(x, y, r, g, b, tag)
    args.state.new_entity(tag) do |p|
      p.x = x
      p.y = y
      p.w = 40
      p.h = 60
      p.r = r
      p.g = g
      p.b = b
      p.path = :solid
      p.dx = 0 # Horizontal Velocity
      p.dy = 0 # Vertical Velocity
      p.on_ground = false
      p.action = :standing
      p.damage = 0.0 # Smash specific mechanic: damage increases knockback
      p.facing = (tag == :one ? 1 : -1) # 1 for right, -1 for left
    end
  end

  # --- 2. Input Processing ---
  def input
    # Process inputs for Player 1 (Keyboard Arrows/Space/J)
    handle_player_input(state.player_one, args.inputs.keyboard, :left, :right, :space, :j)

    # Process inputs for Player 2 (WASD/LShift/K)
    # Using 'A' for left, 'D' for right, 'W' for jump, 'K' for attack
    handle_player_input(state.player_two, args.inputs.keyboard, :a, :d, :w, :k)
  end

  def handle_player_input(player, inputs, key_left, key_right, key_jump, key_attack)
    # Horizontal Movement (Acceleration/Deceleration pattern [4, 5])
    if inputs.key_held.send(key_right)
      player.dx += ACCELERATION
      player.dx = player.dx.lesser(MAX_SPEED) # Limit speed [5-7]
      player.facing = 1
    elsif inputs.key_held.send(key_left)
      player.dx -= ACCELERATION
      player.dx = player.dx.greater(-MAX_SPEED) # Limit speed [4, 6]
      player.facing = -1
    end

    # Jumping (using basic jumping mechanic pattern [2])
    if inputs.key_down.send(key_jump) && player.on_ground
      player.dy = JUMP_POWER
      player.on_ground = false
      player.action = :jumping
    end

    # Basic Attack Generation
    if inputs.key_down.send(key_attack)
      create_hitbox(player)
    end
  end

  def create_hitbox(player)
    # Create a simple hitbox rectangle attached to the player's front side
    hitbox_x = player.x + (player.facing * (player.w / 2))
    state.hitboxes << args.state.new_entity(:hitbox) do |h|
      h.x = hitbox_x
      h.y = player.y + 10
      h.w = 50
      h.h = 40
      h.r = 255; h.g = 255; h.b = 0; h.a = 150 # Yellow/Semi-transparent
      h.lifetime = Kernel.tick_count + 10 # Active for 10 frames (short duration)
      h.owner = player.tag
      h.knockback_force = 5 # Base knockback power
      h.damage_increase = 5 # Damage added to opponent
    end
  end

  # --- 3. Calculation (Physics and Combat) ---
  def calc
    calc_player_physics(state.player_one)
    calc_player_physics(state.player_two)

    calc_combat(state.player_one, state.player_two)
    calc_combat(state.player_two, state.player_one)

    # Clean up expired hitboxes
    state.hitboxes.reject! { |h| Kernel.tick_count >= h.lifetime } # Rejection pattern [8]
  end

  def calc_player_physics(player)
    # Apply friction/slowdown if not moving horizontally [5, 7]
    if args.inputs.left_right == 0 && player.on_ground
      player.dx *= SLOWDOWN_RATE
      player.dx = 0 if player.dx.abs < 0.1
    end

    # Apply Gravity and Movement
    player.x += player.dx
    player.y += player.dy
    player.dy += GRAVITY

    # Handle Stage Collision (Simplified to ground only, similar to Ramp Collision examples [1])
    if player.y < state.ground.h
      player.y = state.ground.h
      player.dy = 0
      player.on_ground = true
      player.action = :standing
    end

    # Boundary Check (Prevent falling off screen left/right)
    if player.x < 0
      player.x = 0
      player.dx = 0
    elsif player.x + player.w > 1280
      player.x = 1280 - player.w
      player.dx = 0
    end
  end

  def calc_combat(attacker, defender)
    state.hitboxes.find_all { |h| h.owner == attacker.tag }.each do |hitbox|
      # Check if hitbox intersects with defender rectangle [8, 9]
      if hitbox.intersect_rect?(defender)

        # 1. Apply Damage Increase
        defender.damage += hitbox.damage_increase

        # 2. Calculate Knockback (Simulated Smash knockback: scales with damage)

        # Calculate knockback strength based on damage (higher damage = higher launch power)
        # Formula is a simplified version: (Base Force + Damage)
        knockback_power = hitbox.knockback_force + (defender.damage * 0.2)

        # Determine launch direction (away from attacker's center)
        # Note: This is an approximation; true Smash physics are complex.
        direction_x = defender.x + defender.w/2 - attacker.x - attacker.w/2

        # Apply force vector to defender (requires vector math concepts [10, 11])
        defender.dx = direction_x.sign * knockback_power.abs
        defender.dy = knockback_power * 0.8 # Launch upward slightly less than horizontal force
        defender.on_ground = false
        defender.action = :knockback

        # Mark hitbox for removal immediately after hit
        hitbox.lifetime = Kernel.tick_count
      end
    end
  end

  # --- 4. Rendering ---
  def render
    # Background
    outputs.solids << [12, 12, 12]

    # Ground
    outputs.solids << state.ground

    # Players
    render_player_entity(state.player_one)
    render_player_entity(state.player_two)

    # Hitboxes (yellow flashes)
    outputs.solids << state.hitboxes

    # Debug Labels (showing damage state)
    outputs.labels << { x: 50, y: 700, text: "P1 Damage: #{state.player_one.damage.to_i}%", r: state.player_one.r, g: state.player_one.g, b: state.player_one.b }
    outputs.labels << { x: 1000, y: 700, text: "P2 Damage: #{state.player_two.damage.to_i}%", r: state.player_two.r, g: state.player_two.g, b: state.player_two.b }
  end

  # Helper to render player, potentially flipping sprite based on direction
  def render_player_entity(player)
    # Using simple solid squares for representation
    outputs.solids << player
  end
end

# DragonRuby entry point
def tick args
  $game ||= SmashLikeGame.new
  $game.args = args
  $game.tick
end

# Reset function for hot reloading
def reset args
  $game = nil
end
NotebookLM can be inaccurate; please double check its responses.

* tetris attack
Building a game similar to Tetris Attack (a tile-matching puzzle game centered around swapping blocks on a rising grid) requires robust grid management, collision handling for the cursor, and complex calculation logic for matching and gravity.
DragonRuby is well-suited for this, utilizing the principles demonstrated in the tile-based samples (like the Map Editor and simple physics collisions) and entity management.
Here is a conceptual code framework focusing on the unique mechanics: Grid Setup, Cursor Movement, and Block Swapping.
Core Game Structure
We will use a class to manage the game state, adhering to the standard DragonRuby defaults, input, calc, render pipeline.
# Constants for the Game Grid
GRID_COLS = 6
GRID_ROWS = 12
TILE_SIZE = 60
BOARD_X_OFFSET = 460 # Center the 6x12 grid (6 * 60 = 360 wide)

class TetrisAttackLikeGame
  attr_gtk

  # --- 1. Initialization (defaults) ---
  def defaults
    # A. Initialize the Board (2D Array of Blocks)
    # We will store blocks as hashes representing their color/type
    if !state.board
      state.board = Array.new(GRID_COLS) { |col| Array.new(GRID_ROWS) { |row| new_block(col, row) } }
      # Start all blocks at the bottom of the screen
      state.board.flatten.each { |b| b.y = b.row * TILE_SIZE }
    end

    # B. Initialize the Cursor (The Player's movable selection box)
    state.cursor ||= {
      col: 1, # Start centered horizontally (cursor spans 2 tiles)
      row: 1,
      w: TILE_SIZE * 2, # Cursor is always 2 tiles wide
      h: TILE_SIZE,
      path: :border, # Use a border for visibility [1, 2]
      r: 255, g: 255, b: 255, a: 150
    }

    # C. Game Status for rising speed
    state.rise_speed ||= 0.5 # Pixels per tick the board rises
    state.rise_accumulator ||= 0.0
  end

  # Helper to create a new block entity at a grid coordinate
  def new_block(col, row)
    {
      col: col,
      row: row,
      x: BOARD_X_OFFSET + col * TILE_SIZE,
      y: row * TILE_SIZE,
      w: TILE_SIZE,
      h: TILE_SIZE,
      type: rand(4), # 4 different block types (0, 1, 2, 3)
      color: case rand(4)
             when 0 then {r: 255, g: 0, b: 0} # Red
             when 1 then {r: 0, g: 255, b: 0} # Green
             when 2 then {r: 0, g: 0, b: 255} # Blue
             when 3 then {r: 255, g: 255, b: 0} # Yellow
             end,
      path: :solid # Rendered as a solid color rectangle
    }
  end

  # --- 2. Input Processing (Input) ---
  def input
    # Movement of the 2x1 Cursor (moving in single tile steps)
    if inputs.keyboard.key_down.up
      state.cursor.row += 1 unless state.cursor.row >= GRID_ROWS - 1
    elsif inputs.keyboard.key_down.down
      state.cursor.row -= 1 unless state.cursor.row <= 0
    end

    if inputs.keyboard.key_down.right
      state.cursor.col += 1 unless state.cursor.col >= GRID_COLS - 2 # Can't move past 4 (since it's 2 tiles wide)
    elsif inputs.keyboard.key_down.left
      state.cursor.col -= 1 unless state.cursor.col <= 0
    end

    # Core Mechanic: Swapping the two blocks inside the cursor
    if inputs.keyboard.key_down.space || inputs.keyboard.key_down.j
      swap_blocks
    end
  end

  # --- Swapping Logic ---
  def swap_blocks
    # Identify the two blocks currently under the cursor (P1: left, P2: right)

    # Block 1 is at (cursor.col, cursor.row)
    block1_data = state.board[state.cursor.col][state.cursor.row]
    # Block 2 is at (cursor.col + 1, cursor.row)
    block2_data = state.board[state.cursor.col + 1][state.cursor.row]

    # We need to swap the content (type, color) but keep the grid location markers (col, row)

    # 1. Temporarily store Block 1's key data
    b1_temp_type = block1_data.type
    b1_temp_color = block1_data.color

    # 2. Assign Block 2's data to Block 1
    block1_data.type = block2_data.type
    block1_data.color = block2_data.color

    # 3. Assign Block 1's stored data to Block 2
    block2_data.type = b1_temp_type
    block2_data.color = b1_temp_color

    # NOTE: In a real game, visual swapping animation needs to be handled here
    # (e.g., setting a temporary dx for the blocks before resetting their position).
  end

  # --- 3. Calculation (calc) ---
  def calc
    # Update cursor screen position based on grid coordinates
    state.cursor.x = BOARD_X_OFFSET + state.cursor.col * TILE_SIZE
    state.cursor.y = state.cursor.row * TILE_SIZE

    # Apply continuous rising motion (vertical scroll)
    state.rise_accumulator += state.rise_speed

    if state.rise_accumulator >= TILE_SIZE # If we have risen a full tile height
      # Logic to add a new row at the bottom and shift all blocks up
      # (This is complex grid manipulation and needs careful implementation
      # to prevent data loss or mismatching indices, similar to how arrays
      # are manipulated in entity examples [3]).

      # For now, just reset accumulator and update block visuals slightly
      state.rise_accumulator -= TILE_SIZE
    end

    # Update all block positions (including the slight rise_accumulator offset)
    state.board.each_with_index do |column, col_index|
      column.each_with_index do |block, row_index|
        # Block position should always align to its (row * TILE_SIZE) + accumulator
        block.x = BOARD_X_OFFSET + block.col * TILE_SIZE
        block.y = block.row * TILE_SIZE + state.rise_accumulator
      end
    end

    # --- Matching and Gravity Placeholder ---
    # Here is where logic for 'AABB Collision' style checks would occur:
    # 1. Check for 3+ matches horizontally/vertically.
    # 2. Mark matches as 'dead' or set a temporary state (e.g., block.clearing = true).
    # 3. Use `reject!` [3, 4] to remove cleared blocks from the array.
    # 4. Implement downward movement (gravity) for blocks above the cleared space (similar to physics entity movement dx/dy [5, 6]).
  end

  # --- 4. Rendering (render) ---
  def render
    # Draw Blocks (use sprites or solids based on the type/color hashes)
    all_blocks = state.board.flatten.map do |b|
      b.merge(x: b.x, y: b.y, **b.color)
    end
    outputs.solids << all_blocks

    # Draw the Cursor (as a border, so we can see the blocks beneath it)
    outputs.borders << state.cursor

    # Render instructional text (optional)
    outputs.labels << {x: 20, y: 700, text: "Tetris Attack Clone (Incomplete)"}
    outputs.labels << {x: 20, y: 680, text: "Arrows: Move Cursor | Space/J: Swap Blocks"}
  end
end

# DragonRuby entry point
def tick args
  $game ||= TetrisAttackLikeGame.new
  $game.args = args
  $game.tick
end
Key Techniques Used
1. Grid Mapping: The game uses integer grid coordinates (col, row) stored directly on the block and cursor entities, which are translated to screen coordinates (x, y) by multiplying by TILE_SIZE. This is similar to how coordinate mapping is handled in the map editor sample and low-resolution games.
2. State Representation: The board is stored as a nested array (state.board), allowing direct access to panels using state.board[col][row]. This centralized state management is a core principle of DragonRuby development.
3. Swapping Mechanism: The core swapping mechanic is achieved by exchanging the properties (like type and color) of the two targeted block hashes, rather than moving the block objects themselves across the grid slots.
4. Collision and Selection: While we don't use intersect_rect? directly on the blocks for movement here, the concept relies on the cursor's hitbox (state.cursor) visually defining which two blocks (which are rectangular entities) are selected, as intersection checks are a primary function of rectangles in the engine.


* battle shmup with slow lasers
Building a simple shoot 'em up game in DragonRuby is straightforward using the built-in physics and entity management systems described in the documentation.
Your requirements—shooting lasers, slow movement, and reflection off the screen walls—can be directly implemented using concepts demonstrated in samples like "Entities," "Moving Objects," and various "Physics and Collisions" examples.
The standard DragonRuby structure involves delegating game logic across defaults (initialization), input (user controls), calc (physics/updates), and render (drawing).
Core Game Components
1. Game Initialization (defaults args)
We define the player and initialize the collection that will hold the lasers (or bullets). The use of args.state.new_entity is a recommended pattern for complex objects.
def defaults args
  # Player Entity Setup
  args.state.player ||= args.state.new_entity(:player) do |p|
    p.x = 600
    p.y = 100
    p.w = 50
    p.h = 50
    p.path = 'sprites/square/blue.png' # Requires a blue sprite image or use :solid
    p.speed = 5
  end

  # Laser Collection Setup
  args.state.lasers ||= [] # Lasers/bullets should be stored in an array/collection [4]
end
2. Player Input and Shooting Logic
Player movement is handled by checking args.inputs.keyboard.key_held or directional inputs. Shooting requires detecting a key_down event (like the spacebar or 'j' key).
def input args
  # Movement (e.g., horizontal movement)
  args.state.player.x += args.inputs.left_right * args.state.player.speed

  # Shooting Laser
  # Using key_down.space ensures the player fires only once per key press
  if args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.j
    fire_laser args
  end
end

# Function to create and configure the laser entity
def fire_laser args
  laser_w = 10
  laser_h = 10

  # Create a new laser entity [1]
  args.state.lasers << args.state.new_entity(:laser) do |l|
    # Start the laser centered above the player
    l.x = args.state.player.x + (args.state.player.w / 2) - (laser_w / 2)
    l.y = args.state.player.y + args.state.player.h
    l.w = laser_w
    l.h = laser_h
    l.path = :solid
    l.r = 255
    l.g = 0
    l.b = 0

    # Requirement: Slow movement
    # Setting dx/dy to small values (e.g., 1.5 or 2.0) ensures slow movement.
    # Compare this to bullet speed examples which might be 5 or higher [4, 8].
    l.dx = 0.randomize(:ratio, :sign) * 1.5 # Slow horizontal drift
    l.dy = 1.5 # Slow upward velocity
  end
end
3. Laser Movement and Wall Reflection (calc args)
The calculation step moves the objects using their velocity (dx and dy) and checks for collision with boundaries, performing the requested reflection. The pattern for boundary collision is explicitly shown in physics samples: check if the object is outside the bounds (0 to 1280 for X, 0 to 720 for Y) and reverse the direction (dx *= -1 or dy *= -1).
def calc args
  screen_width = 1280
  screen_height = 720

  args.state.lasers.each do |laser|
    # Apply movement based on velocity
    laser.x += laser.dx
    laser.y += laser.dy

    # --- Reflection Logic ---

    # Check horizontal boundaries (left wall: x < 0; right wall: x + w > 1280)
    if laser.x < 0
      laser.x = 0 # Clamp position
      laser.dx *= -1 # Reverse horizontal direction [9, 10]
    elsif laser.x + laser.w > screen_width
      laser.x = screen_width - laser.w # Clamp position
      laser.dx *= -1 # Reverse horizontal direction [9, 10]
    end

    # Check vertical boundaries (bottom wall: y < 0; top wall: y + h > 720)
    if laser.y < 0
      laser.y = 0 # Clamp position
      laser.dy *= -1 # Reverse vertical direction [9, 10]
    elsif laser.y + laser.h > screen_height
      laser.y = screen_height - laser.h # Clamp position
      laser.dy *= -1 # Reverse vertical direction [9, 10]
    end
  end
end
4. Rendering
The final step is to display the player and all active lasers using args.outputs.sprites or args.outputs.solids.
def render args
  # Render the Player
  args.outputs.sprites << args.state.player

  # Render the Lasers (or solids, since they were defined as path: :solid in this example)
  args.outputs.solids << args.state.lasers
end
This implementation leverages key concepts found across DragonRuby samples:
1. State Management: Using args.state to store objects like the player and a collection of lasers.
2. Input Handling: Capturing specific key presses using args.inputs.keyboard.key_down for actions.
3. Basic Physics: Implementing deterministic movement using dx and dy for velocity.
4. Boundary Interaction: Achieving reflection by inverting the velocity vector component (dx or dy) upon collision with the screen edges.
This design creates a foundation for a fully functional shoot 'em up with slow, bouncing lasers.
