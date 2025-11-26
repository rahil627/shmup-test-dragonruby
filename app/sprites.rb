#!/usr/bin/env ruby

module Sprites # or entities?
  # just a place to throw all the sprite/entity hashes
  # ..they just took up too much screen space..!!
  
  def make_player1
    make_player x: 400,
                y: 320.randomize(:sign, :ratio),
                angle: 180,
                path: 'sprites/circle/violet.png'
    # color: { r: 255, g: 90, b: 90 }
  end

  def make_player2
    make_player x: 800,
                y: 250.randomize(:sign, :ratio),
                angle: 0,
                path: 'sprites/circle/green.png'
    # color: { r: 110, g: 140, b: 255 }
  end

  
  def make_player x:, y:, angle:, path:; #, color:;
    # dead: false,
    # color: color,
    # created_at: Kernel.tick_count,
    {x: x,
     y: y,
     w: 80,
     h: 80,
     path: path,
     # a: 255,
     angle: angle,
     anchor_x: 0.5,
     anchor_y: 0.5,
     vx: 0,
     vy: 0,
     trash: false, # for garbage collection
     # dead?
     cooldown: 0,
     health: 10,
     score: 0 }
  end


  def make_laser a # hash with x, y, dx, dy
    # returns entity hash
    w = args.state.c.laser_width ||= 20
    
    # TODO: can provide angle or vector or both?
    # angle = 0
    # if (a.angle) # TODO: a.angle or a['angle']?
    #   angle = a.angle
    #   dx = Math.sin(angle)
    #   dy = Math.cos(angle)
    # else
    #   dx = a.dx
    #   dy = a.dy
    #   angle = vector_to_angle(a.dx, a.dy) - 90
    # end

    {
      x:     a.x,
      y:     a.y,
      anchor_x: 0.5, # center of width of laser
      # anchor_y: 0.5,
      w:     w,
      h:     1, # 0 might cause multiplication problem..
      path: :pixel,
      angle: vector_to_angle(a.dx, a.dy) - 90,
      # Rotation of the sprite in degrees (default value is 0). Rotation occurs around the center of the sprite. The point of rotation can be changed using angle_anchor_x and angle_anchor_y.
      # angle_anchor_x: 0.5,
      angle_anchor_y: 0, # don't quite remember.. bottom of length of laser?
      r:     255 * rand, g: 255 * rand, b: 255 * rand, # white by default
      # vx:    10 * dx + args.state.player[:vx] / 7.5,
      # vy: 10 * dy + args.state.player[:vy] / 7.5, # Factor in a bit of the player's velocity

      # extra fields
      # player: player_id
      trash: false, # not necessary, as ||= and {}.reject! will work without it
      dx: a.dx, # more convenient than angle..
      dy: a.dy,
      head: { x: a.x, y: a.y, w: 5, h: 5, path: :pixel, r: 0, g: 255, b: 0}, # composition..??
    }
  end



    
end
