
# TODO: merge in dragonruby.txt
# TODO: try org-mode with this file!!

# discord
https://discord.dragonruby.org

# some design quotes from amir
**"Start your game as simply as possible. One file, one method (tick).**

**"A game is a body-of-state that goes through a pipeline of data transforms, and returns what should be rendered to the screen. Your single method will eventually become a collection of methods that are executed in order (it’s procedural in nature given that it’s a pipeline that transforms data/game state)."**

wrt incremental evolution: **a system in it's simplest form is a function that acts on data. that's what I start with**

**my "entity" is a hash. and my component is keys on that hash.**
  - **start with this for entity architecture**

**ecs in its simplest form is a function that operates on a hash with an assumed set of keys/properties**




# docs
single file static local docs
  - file:///C:/Users/ra/my-stuff/repos/dragonruby-windows-amd64/docs/static/docs.html
  
# philosophy
TODO: read

# setup
TODO: need to setup helix workspace, so that i can easily access samples with file picker, yet still get autocomplete via lsp (which depends on the workspace location)

# lsp
install the solargraph gem
get the dr yard docs repo
in mygame folder, run `solargraph config`
set up the relative directory to the yard docs repo and app folder

# repo
1. Your public repository needs only to contain the contents of ./mygame. This approach is the cleanest and doesn't require your .gitignore to be polluted with DragonRuby specific files.
2. edit .gitignore (see docs)
3. edit .gitgnore: add `/tmp/` and `/logs/`

The DragonRuby binary/package is designed to be committed in its entirety with your source code (it’s why we keep it small). This protects the “shelf life” for commercial games. 3 years from now, we might be on a vastly different version of the engine. But you know that the code you’ve written will definitely work with the version that was committed to source control.

# deploy
see docs
itch
mobile
  - only pro version

# args
args.outputs
  - draw things, append arrays with << operator
  
args.inputs

args.state
args.state.player[x:]
args.state.player.x
  - a place you can hang your own data. It's an open data structure that allows you to define properties that are arbitrarily nested. You don't need to define any kind of class.
  - it seems to be nested hashes
  - dot notation has the benefit of being easy to refactor if player evolves into a class
  - standard hash notation currently has the benefit of auto-complete working
  
args.geometry

args.cvars
 - Hash contains metadata pulled from the files under the ./metadata directory. To get the keys that are available type $args.cvars.keys in the Console.
   - args.cvars["game_metadata.version"].value.to_s

args.layout
  - Layout provides apis for placing primitives on a virtual grid that's within the "safe area" accross all platforms. This virtual grid is useful for rendering static controls (buttons, menu items, configuration screens, etc).

args.grid
  - Provides information about the screen and game canvas.
  
args.gtk
  - core runtime class
  - $gtk.function(...) or GTK.function(...)
    - or, if in the main tick, args.gtk.function
  - array (extensions)
      - **each**
      - map_2d
  - macros
    - attr = attr_accessor
    - **attr_gtk** passing args for you
  - contains a bunch of environment/utility functions, SDL stuff, etc.
    - window related stuff
    - mouse related stuff
    - request_quit / quit_requested?
    - platform?
    - exec
      - Given an OS dependent cli command represented as a string, this function executes the command and returns a string representing the results.
        - **connect the shell to DR!!**
    - system
      - same as above, but put outputs to the console (returns nil)
  - file i/o
    - within the same directory as the the dragonruby binary
  - network i/o
    - start a http server..!
  - dev support functions
    - lots..!
    - use these in the dev console
    - reset
    - slowmo!
    - replay
    - recording
    - ..hopefully there's autocomplete..!
    
# troubleshoot performance
TODO: though shouldn't pre-optimize, def need to know some good habits







# getting started / tutorial
TODO: can extract the important bits out later, once i'm more comfy with the engine and language


# hello world
# game loop/stick runs 60 frames/second

```ruby
# in main.rb
def tick args
  args.outputs.labels << [580, 400, 'Hello World!']
end
```

this is all you need to have a game!! hoooolyyyy shiiiiiitttt!!! :mind_explosion:

"args" is a magic structure with lots of information in it. You can set variables in there for your own game state, and every frame it will updated if keys are pressed, joysticks moved, mice clicked, etc.

the game uses the outputs object to draw things. you use arrays to draw things. in this case [x, y, text]

The "<<" thing says "append this array onto the list of them at args.outputs.labels)

Once your tick function finishes, we look at all the arrays you made and figure out how to draw it. You don't need to know about graphics APIs. You're just setting up some arrays! DragonRuby clears out these arrays every frame, so you just need to add what you need _right now_ each time.




# sprites
Each 2D image in DragonRuby is called a "sprite," and to use them, you just make sure they exist in a reasonable file format (png, jpg, gif, bmp, etc) and specify them by filename. The first time you use one, DragonRuby will load it and keep it in video memory for fast access in the future. If you use a filename that doesn't exist, you get a fun checkerboard pattern!

```ruby
def tick args
  args.outputs.labels  << [580, 400, 'Hello World!']
  args.outputs.sprites << [576, 100, 128, 101, 'dragonruby.png']
end
```


NOTE: when you save main.rb, DragonRuby will notice and reload your program.

That .sprites line says "add a sprite to the list of sprites we're drawing, and draw it at position (576, 100) at a size of 128x101 pixels". You can find the image to draw at dragonruby.png.




# coordinates
**(0, 0) is the bottom left corner of the screen, and positive numbers go up and to the right.** This is more "geometrically correct," even if it's not how you remember doing 2D graphics, but we chose this for a simpler reason: when you're making Super Mario Brothers and you want Mario to jump, you should be able to add to Mario's y position as he goes up and subtract as he falls. It makes things easier to understand.
  - yesssss!!! love this reasoning! design > formalisms

**your game screen is _always_ 1280x720 pixels.** If you resize the window, we will scale and letterbox everything appropriately, so you never have to worry about different resolutions.

``` ruby
def tick args
  args.state.rotation  ||= 0
  args.outputs.labels  << [580, 400, 'Hello World!' ]
  args.outputs.sprites << [576, 100, 128, 101, 'dragonruby.png', args.state.rotation]
  args.state.rotation  -= 1
end
```

**args.state is a place you can hang your own data.** It's an open data structure that allows you to define properties that are arbitrarily nested. You don't need to define any kind of class.

In this case, the current rotation of our sprite, which is happily spinning at 60 frames per second. If you don't specify rotation (or alpha, or color modulation, or a source rectangle, etc), **DragonRuby picks a reasonable default,** and **the array is ordered by the most likely things you need to tell us:** position, size, name.



# there is no delta time
One thing we decided to do in DragonRuby is not make you worry about delta time: **your function runs at 60 frames per second (about 16 milliseconds) and that's that.** Having to worry about framerate is something massive triple-AAA games do, but for fun little 2D games? You'd have to work really hard to not hit 60fps. All your drawing is happening on a GPU designed to run Fortnite quickly; it can definitely handle this.

Since we didn't make you worry about delta time, you can just move the rotation by 1 every time and it works without you having to keep track of time and math. Want it to move faster? Subtract 2.
  - hmmmm, interesting choice..



# handle user input
```ruby
def tick args
  args.state.rotation ||= 0
  args.state.x ||= 576 # default
  args.state.y ||= 100

  if args.inputs.mouse.click
    args.state.x = args.inputs.mouse.click.point.x - 64
    args.state.y = args.inputs.mouse.click.point.y - 50
  end

  args.outputs.labels  << [580, 400, 'Hello World!']
  args.outputs.sprites << [args.state.x,
                           args.state.y,
                           128,
                           101,
                           'dragonruby.png',
                           args.state.rotation]

  args.state.rotation -= 1
end
```

Everywhere you click your mouse, the image moves there. We set a default location for it with args.state.x ||= 576, and then we change those variables when we see the mouse button in action. You can get at the keyboard and game controllers in similar ways.

