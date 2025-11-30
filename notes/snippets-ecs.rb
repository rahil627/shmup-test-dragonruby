

# amir's thoughts on ECS
**my "entity" is a hash. and my component is keys on that hash.**
  - **start with this for entity architecture**

**ecs in its simplest form is a function that operates on a hash with an assumed set of keys/properties**

# https://www.reddit.com/r/ruby/comments/v87oyx/comment/ibrq1w1/?utm_source=share&utm_medium=mweb3x&utm_name=mweb3xcss&utm_term=1&utm_content=share_button
#  - compare:
#    - https://github.com/DragonRuby/dragonruby-game-toolkit-contrib/blob/main/samples/99_genre_platformer/gorillas_basic/app/main.rb
#    - https://github.com/guitsaru/draco/tree/main/samples/gorillas-basic/app

# a few ECS architectures from the discord

# poor man's ECS by amir
def tick args
  args.state.entities ||= {}
  args.state.entities.player ||= {
    id: :player,
    x: 0,
    y: 0,
    w: 100,
    h: 100,
    path: "sprites/square/blue.png",
    systems: {
      drawable: true,
      moveable: true
    }
  }

  tick_movable_system args
  tick_drawable_system args
end

def tick_movable_system args
  entities_with_system(args, :moveable).each do |v|
    v.x += 1
    v.x = 0 if v.x > 1280
  end
end

def tick_drawable_system args
  args.outputs.primitives << entities_with_system(args, :drawable)
end

def entities_with_system args, system_name
  args.state
      .entities
      .values
      .find_all { |v| v.systems[system_name] }
end



# ECS using built-in language (no meta-programming?) by amir
class Entity
  def self.system_functions
    @system_functions ||= { }
    @system_functions
  end

  def tick args
    self.class.system_functions.each { |m, block| block.call args, self }
  end
end

module System
  def tick_method m, &block
    self.define_singleton_method :included { |base| base.system_functions[m] = block }
  end
end

module Drawable
  extend System

  attr :x, :y, :w, :h, :path

  tick_method :tick_drawable do |args, component|
    args.outputs.primitives << { x: component.x,
                                 y: component.y,
                                 w: component.w,
                                 h: component.h,
                                 path: component.path }
  end
end

module Movable
  extend System

  attr :x

  tick_method :tick_movable do |args, component|
    component.x += 1
  end
end

class Player < Entity
  include Drawable
  include Movable

  def initialize
    @x = 0
    @y = 0
    @w = 32
    @h = 32
    @path = 'sprites/square/blue.png'
  end
end

def tick args
  args.state.entities ||= [Player.new]
  args.state.entities.each { |e| e.tick args }
end

GTK.reset




# ECS in a much simpler way, by amir
class Draw
  def self.tick args, component
    args.outputs.primitives << { x: component.x,
                                 y: component.y,
                                 w: component.w,
                                 h: component.h,
                                 path: component.path }
  end
end

class Move
  def self.tick args, component
    component.x += 1
    component.x = 0 if component.x > 1280
  end
end

def tick args
  args.state.player ||= { x: 0, y: 0, w: 64, h: 64, path: 'sprites/square/blue.png' }
  Move.tick args, args.state.player
  Draw.tick args, args.state.player
end

GTK.reset



# a totally fine "ECS"
module Drawable
  attr :x, :y, :w, :h
end

class Player
  include Drawable
end

def render_system args, entity
  return if !entity.is_a? Drawable
  args.outputs.primitives << { x: entity.x ... }
end


# from kfischer-okarin
# https://github.com/kfischer-okarin/roguelike-base/blob/main/mygame/lib/component_definitions.rb
  class Component
    def initialize(name)
      @name = name
      @default_values = {}
      @attributes = {}
      @entity_attribute = {}
      @methods = {}
    end

    def attribute(name, default: nil)
      @default_values[name] = default if default
      @attributes[name] = true
    end

    def entity_attribute(name)
      @entity_attribute[name] = true
    end

    def method(name, &block)
      @methods[name] = block
    end

    def build_default_values
      DeepDup.dup(@default_values)
    end

    def attach_to(entity, **attributes)
      entity_component_data = entity.instance_variable_get(:@entity_component_data)
      component_data = entity_component_data[@name] = build_default_values.merge(attributes)

      @attributes.each_key do |name|
        entity.define_singleton_method(name) do
          component_data[name]
        end

        entity.define_singleton_method("#{name}=") do |value|
          component_data[name] = value
        end
      end

      @entity_attribute.each_key do |name|
        entity.define_singleton_method(name) do
          @entity_store[component_data[name]]
        end

        entity.define_singleton_method("#{name}=") do |value|
          component_data[name] = value.id
        end
      end

      @methods.each do |name, block|
        entity.define_singleton_method(name, &block)
      end
    end

    def to_s
      "Component(#{@name})"
    end
  end
end


class ComponentDefinitions
  def initialize
    @definitions = {}
  end

  def define(name, &block)
    component = Component.new(name)
    component.instance_eval(&block)
    @definitions[name] = component
  end

  def [](name)
    @definitions[name]
  end

  def defined_types
    @definitions.keys
  end

  def clear
    @definit
