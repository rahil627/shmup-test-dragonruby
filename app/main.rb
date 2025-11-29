# from VERSION.txt
# date: Wed Nov 5 02:30:27 CST 2025
# git: ecab86c436a1854ab3c424ee5d82fefdbbba103c

require_relative "common"
require_relative "input"
require_relative "sprites"


# TODO: main todo list
# $game ||= Game.new # auto-init deprecated, check ruby's safe operator
def boot args
  # args.state = {} # disables auto-init of nil
end

# create a laser collection
#  - includes laser + reflections

# BUG: second player stopped shooting after the first shot ;(

#  - DESIGN: how to determine the length / when it should stop?
#    - just try playing with various lengths..
#    - first try with just one laser, and both players must survive/run

# DESIGN: maybe can have abilities:
#  1. portal
#    - my initial idea: shoot a portal, press again to deploy, then it reflects lasers depending on angle
#  - cut laser
#  - reflect / alter direction of laser
#  - jump / teleport

# ART: doesn't have to be lasers..
#  - could be a monster!.. a dragon?


def tick args
  # args.gtk.suppress_mailbox = false # for communication to ide
  #  - TODO: ERROR: probably just some old info ai found..
  $game = Game.new if Kernel.tick_count.zero?
  $game.args = args # for attr_gtk macro
  $game.tick
end
# dragonRuby looks for this function and calls it every frame, 60 times a second.
# "args" is a magic structure with lots of information in it. You can set variables in there for your own game state, and every frame it will updated if keys are pressed, joysticks moved, mice clicked, etc.
# Once your tick function finishes, we look at all the arrays you made (under outputs) and figure out how to draw it. You don't need to know about graphics APIs. You're just setting up some arrays! DragonRuby clears out these arrays every frame, so you just need to add what you need _right now_ each time.


class Game # TODO: how come i can't see Game in the dev console..??
  attr_gtk # NOTE: included modules work fine too! :D

  include Common
  include Input
  include Sprites
  # having everything as a module and including it can get hairy, as they share a single namespace.. but i think that's just the way it is... at least in C it is!
  # without classes (save this one), it's basically the same as one giant file!
  # you can arbitrarily create modules as you want, to segment code
  # and you can arbitrarily creates files as you want, to further segment code!
  # NOTE: can seperate code into modules by main tick functions!
  #   - init, input, logic, output, make sprites
  #   - yay! no need to think about confusing objects!!
  #   - ..but for such a simple idea, just keep it one file..
  # TODO: should just set up code folding for now..
  
  # main game loop
  # @param args [GTK::Args]
  def tick
    init if Kernel.tick_count.zero? # thanks to pvande # TODO: test return after this?
    return if pause_because_unfocused? # from defaults module
    handle_input # from input module
    handle_logic # most of the game goes here
    take_out_the_trash
    handle_output # vs render
  end


  
  ### INIT
  
  def reset
    game_init
  end

  def init
    #default_pre_init
    default_init # app_init
    game_init
    #default_post_init
  end
  
  def game_init
    puts "init"
    
    # just note some state data here
    # state.c = constants

    # TODO: surely somewhere..
    # just kept using hard-coded ints for now..
    # state.screen = {x: 0, y: 0, h: 720, w: 1280}
    state.screen = {x: 0, y: 0, h: 720/2, w: 1280/2}
    # NOTE: Also: your game screen is _always_ 1280x720 pixels. If you resize the window, we will scale and letterbox everything appropriately, so you never have to worry about different resolutions.
    
    state.players = []
    state.lasers = []
    # arrays of hashes
    #   - much simpler than an entity-component-system! :)

    # NOTE: move this to update player
    # p = state.player # must do after lazy init
    # p[:r] = p[:g] = p[:b] = (p[:health] * 25.5).clamp(0, 255)
    
    state.players << make_player1
    state.players << make_player2

  end


  
  ### TRASH

  def take_out_the_trash
  # remove arrays 'n hashes all at once
    # "For what it’s worth, you could implement this behavior yourself — instead of calling “delete”, you could set obj.garbage = true. After your iteration, then you only need array.reject!(&:garbage) to clean up." - pvande
    state.players.reject!(&:trash)

    state.lasers.reject!(&:trash) # TODO: learn &:key
    # INCOMPLETE: trash the associated laser segments too
    # WAIT: until i setup ruby.. no clue how reject works.. maybe it returns the things it rejects..
    #   - check the rejected laser's parent_id
    #   - if 0, get sprite.id
    #   - trash all that share that parent_id
  end


  
  ### OUTPUT
  
  def handle_output
    # output at the end
    outputs.background_color = [128, 0, 128]

    outputs.sprites << [state.players, state.lasers]
    
    state.lasers.each do |l|
      outputs.sprites << l.head
    end

    
    # from sample
    # state.clear! if state.player[:health] < 0 # Reset the game if the player's health drops below zero
  end



  
  ### LOGIC
  
  def handle_logic
    # store_inputs / handle_device_input

    # handle input-affected stuff
    move_players
    add_players_shots

    move_lasers
    #  - extend
    #  - reflect
    #    - add new laser

    # TODO:
    # check_laser_collisions
    #   - do after reflect and add_players_shots, 'cause they add new lasers
  end


  def move_players
    # p = state.player
    state.players.each do |p|

      s = p[:s] ||= 0.75 # speed
      dx, dy = state.in.move_vector

      # TODO: use anchor_x/y and angle_anchor_x to turn sprite
      p[:angle] = vector_to_angle(dx, dy)

      # Take the weighted average of the old velocities and the desired velocities.
      # Since move_directional_vector returns values between -1 and 1,
      #   and we want to limit the speed to 7.5, we multiply dx and dy by 7.5*0.1 to get 0.75
      p[:vx] = p[:vx] * 0.9 + dx * s
      p[:vy] = p[:vy] * 0.9 + dy * s

      # move
      p.x += p[:vx]
      p.y += p[:vy]

      # bound to screen
      p.x = p.x.clamp(0, 1201)
      p.y = p.y.clamp(0, 640)
    end
  end


  def add_players_shots
    state.players.each do |p|

      p[:cooldown] -= 1
      return if p[:cooldown] > 0
      
      cooldown_length = p[:cooldown_length] ||= 60 # 1/second
      
      dx, dy = state.in.shoot_vector
      return if dx == 0 and dy == 0 # if no input, return early

      # add a new bullet to the list of player bullets
      # NOTE: at the moment, i don't track this: all lasers hurt every player
      
      w = p.w
      h = p.h

      x = p.x + w/2 * dx
      y = p.y + h/2 * dy
      state.lasers << (make_laser_segment ({x: x, y: y, dx: dx, dy: dy, parent_id: 0}))
      
      # vs seperate sprite
      # state.laser_heads << { x: x, y: y, w: 5, h: 5, path: 'sprites/circle/green.png', angle: vector_to_angle(dx, dy) }

      p[:cooldown] = cooldown_length # reset the cooldown
    end
  end

  
  def move_lasers
    state.lasers.each do |l|

      s = state.c.laser_speed ||= 1 # speed, 1/720 per tick..?

      # extend
      l.h += s

      # calculate from angle and length
      # distance = l.h
      # x = l.x + distance * (Math.cos l.angle.to_radians)
      # y = l.y + distance * (Math.sin l.angle.to_radians)

      # just create a point/sprite and update every frame instead
      vx = l.dx * s
      vy = l.dy * s
      l.head.x += vx
      l.head.y += vy

      # when laser.head hits a wall, reflect
      if off_screen_or_on_the_edge? l.head
        
        # add a reflecting laser
        
        # reflect
        # angle vs vector impl
        # l.angle = reflect_angle l.angle

        # vector is easier to handle here..
        if off_screen_or_on_the_edge_left_right? l.head
          l.dx *= -1
        else #if off_screen_or_on_the_edge_top_bottom? l
          l.dy *= -1
        end
        
        state.lasers << (make_laser_segment ({x: l.head.x, y: l.head.y, dx: l.dx, dy: l.dy, parent_id: l.id }))
      end

    end
  end

  def off_screen_or_on_the_edge_top_bottom? e
    e.y <= 0 - e.h || e.y >= 720 + e.h
  end

  def off_screen_or_on_the_edge_left_right? e
    e.x <= 0 - e.w || e.x >= 1280 + e.w
  end

  
  def check_laser_collisions
    # TODO: incomplete
    state.lasers.each do |l| # loop players or lasers? no player port frame advantage!
      state.players.each do |p|

        # TODO: dunno about any of this, it's from the sample
        # state.enemies.reject! do |enemy| # TODO: reject, but no conditional..?
        # state.player_bullets.any? do |bullet| # TODO: LEARN: any, no conditional
        # TODO: should center sprite anchors, especially player
        #   - Check if enemy and player are within 20 pixels of each other (i.e. overlapping)
        if 1000 > (l.x - p.x ** 2 + (l.y - p.y) ** 2)

          # TODO: pause game here
          # TODO: highlight collision point

          # l.trash ||= true
          #  - nahhh, keep laser
          # kill player
          p.trash ||= true
        end
        
      end
    end
  end



end # class game
