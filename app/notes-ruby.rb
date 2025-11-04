# TODO: merge in ruby.txt



# advanced

## seeems super useful, can use right now

options = { font_size: 12, font_family: "Arial" }
merged_options = { font_size: 10, color: "blue" }.merge(options)
puts merged_options.inspect
# Outputs: {:font_size=>12, :color=>"blue", :font_family=>"Arial"}
  # merge hashes!!

module StringExtensions
  refine String do
    def shout
      upcase + "!!!"
    end
  end
end

using StringExtensions

puts "hello".shout  # Outputs: HELLO!!!
  # extensions or "refinements for scoped monkey-patching"
    # very very useful!!


user = { name: "Alice", age: 30, address: { city: "Wonderland", zip: "12345" } }

case user
in { name:, address: { city:, zip: } }
  puts "#{name} lives in #{city}, ZIP: #{zip}"
else
  puts "No match"
end
# Outputs: Alice lives in Wonderland, ZIP: 12345
  # hash pattern matching!! very useful!!
  
  
  
  

# from samples, or from ai but i've seen it before


numbers = [1, 2, 3, 4, 5]
squared = numbers.map { |n| n * n }  # Squares each element
evens = numbers.select { |n| n.even? }  # Selects only even numbers
puts numbers.any?(&:even?)  # Outputs: true
puts numbers.all? { |n| n > 0 }  # Outputs: true
unique_numbers = numbers.uniq
  # data transformation
  
people = [{ name: "Alice", age: 30 }, { name: "Bob", age: 25 }]
person = people.find { |p| p[:age] > 28 }
puts person[:name]  # Outputs: Alice
  # TODO: merge into above examples


if object&.method
  # Do something if object and method exist (not nil)
end
  # safe navigation operator (&.)

enemies = [{ type: "goomba", alive: true }, { type: "koopa", alive: true }, { type: "goomba", alive: false }, { type: "koopa", alive: true }]
alive_enemies, dead_enemies = enemies.partition(&:alive) # splits into alive group and the rest
  # tuple(?).partition
  
names = ["alice", "bob", "carol"]
capitalized_names = names.map(&:capitalize)
  # symbol to proc shorthand
  
numbers = [1, 2, 3, 4, 5]
sum = numbers.reduce(&:+)
puts sum  # Outputs: 15
  # use & to convert a symbol to a block
  
  

  
  





# from ai:

## the more intersting ones for games

str = "hello"
str.freeze
str.upcase!  # Raises an error: can't modify frozen String
  # freeze an object to make it immutable!!

lazy_enum = (1..Float::INFINITY).lazy.map { |x| x * x }.take(5)
puts lazy_enum.to_a  # Outputs: [1, 4, 9, 16, 25]
  # hmmmmm
  
  
def fibonacci(n, memo = {})
  return n if n <= 1
  memo[n] ||= fibonacci(n - 1, memo) + fibonacci(n - 2, memo)
end
  # this one looks interesting for optimizing calculations..
  
class ExpensiveCalculator
  def initialize
    @memo = {}
  end

  def expensive_method(x)
    @memo[x] ||= x ** x
  end
end

calc = ExpensiveCalculator.new
puts calc.expensive_method(3)  # Outputs: 27
  # hmmmm
  # TODO: move this to snippets


(1..10).tap { |x| puts "original: #{x.inspect}" }
        .to_a
        .tap { |x| puts "array: #{x.inspect}" }
        .select { |x| x.even? }
        .tap { |x| puts "evens: #{x.inspect}" }
  # tap method-chaining.. hmmmmm
  
  
  
def call_block
  yield if block_given?
end

call_block { puts "Hello from the block!" }

proc_example = Proc.new { |x| puts x * 2 }
proc_example.call(3)  # Outputs: 6
  # blocks 'n procs, hmmmmm


class Example
  def hello
    "Hello, world!"
  end
end
example = Example.new
puts example.__send__(:hello)  # Outputs: Hello, world!
  # using send to call a method by name
  
  
  
  
  
  
  
## the more standard stuff

a, b = b, a
  # swap vars
  
text = "The quick brown fox"
modified_text = text.gsub("quick", "slow")
puts modified_text  # Outputs: The slow brown fox
  # quick string manipulation

case [1, "hello", 3.0]
in [Integer, String, Float]
  puts "Matched!"
else
  puts "No match"
end
  # pattern matching
  
  
  
result = Integer("not a number") rescue nil
puts result  # Outputs: nil
  # inline exception handling
    # neat!!
  
  
result = begin
           1 / 0
         rescue ZeroDivisionError
           "Cannot divide by zero"
         end
puts result  # Outputs: Cannot divide by zero
  # exception handling
  
user = User.new.tap do |u|
  u.name = "John"
  u.email = "john@example.com"
end
  # tap for cleaner code
  # don't quite understand this one..








## functional stuff

class MyClass
  def say_hello
    "Hello!"
  end
end

obj = MyClass.new
method_obj = obj.method(:say_hello)
puts method_obj.call  # Outputs: Hello!
  # get the method









# basics

# imports
require 'path/to/file_name'
  # relative to working directory
require_relative 'file_name'
  # relative to the current file!
autoload :SomeClass, 'some_class'
  # lazy load
    # The 'some_class.rb' file will only be loaded when SomeClass is accessed
SomeClass.new

include 'ModuleName'
  # can include to top-level context
  # or to classes


## branch, assignment
return if args.state.player[:cooldown] > 0
  # statement if condition

return unless args.state.player[:cooldown] <= 0
  # if not

# WARN: the only values that can fail conditional checks are false and nil

return if args.state.c.init # returns true?

||=
  # Whatever is on the left OR assign to the right
  # "Here's a fun Ruby thing: args.state.rotation ||= 0 is shorthand for "if args.state.rotation isn't initialized, set it to zero." It's a nice way to embed your initialization code right next to where you need the variable."

# WARN: don't use booleans with ||=
||= false
  # will never work but that's usually ok since what was in the variable before is nil which is as good as false in most cases
||= true
  # but the real trap is ||= true which will always overwrite the value with true not only the first time 
  # since a ||= b is just  a = (a || b), actually a || (a = b) (slightly different) which in case of true will never end well 😛  because false || true will always be true 😛


# functions
def attack damage, enemy
  # don't forget the comma!
end

def attack damage:, enemy:
  enemy.health -= damage
end

attack 3, goomba
  # order-based args
    # re-factoring can easily break the order
attack damage: 3, enemy: goomba
  # keyword args
    # far more scalable
    

def f(arg) end
f (a: 22, b: 33)
f {a: 22, b: 33} # same

def f(a:, b:) end
f (a: 22, b: 33)
f {a: 22, b: 33}
hash_arg = {a: 22, b: 33}
kw_arg_function hash_arg # deprecated in v3/v3.1 mruby
kw_arg_function **hash_arg # workaround

hash_gen_keywords {a:, b:, c:} # -> {a: a, b: b, c: c}

make_laser args, a
make_laser args, {x: x, y: y, w: l, h: l, dx: dx, dy: dy}

# DragonRuby's recommended use of parenthesis (inner function has parenthesis).
puts (add_one_to 3) # inner
puts add_one_to(3) # "conventional"
puts(add_one_to 3) # outer
puts(add_one_to(3)) # all
  
# method chaining
player.x = player.x.add(dx).clamp(0)
  # there are many methods added to objects to allow expressing things this way



# hashes and arrays
Array is one of the most powerful classes in Ruby and a very fundamental component of Game Toolkit.

An Array is an ordered, integer-indexed collection of objects, called elements. Any object (even another array) may be an array element, and an array can contain objects of different types.

Arrays in ruby are dynamic.

A Hash has certain similarities to an Array, but:
An Array index is always an Integer.
A Hash key can be (almost) any object.




**hash
*array
  # These are splat operators, they'll deconstruct your hash/array into arguments for a method. 

# destructure
array = [10, 20]
x, y = array # destructuring here is position based

# using spread (reverse splat?) for remaining
player = [5, 5, "Player 1", 5, 5] # x, y, name, w, h
player_x, player_y, name, *player_size = player # 5, 5, Player 1, [5, 5]

# splat operator

## for args
target = { x: 50, y: 50 }
def move_to(x:, y:)
  # moves player to x, y
end
move_to(**target)
  # hash splat

target = [50, 50]
def move_to(x, y)
  # moves player to x, y
end
move_to(*target)
  # array splat

old_hash = { a: 1, b: 2 }
hash = { a: 5, **old_hash, b: 6 } # => { a: 1, b: 6 }
  # args replaced by order of precedence

old_array = [2, 3, 4 , 5]
array = [ 1, 2, *old_array, 5, 6] # => [1, 2, 2, 3, 4, 5, 5, 6]
  # not for arrays tho..

"hashsplat is useful for moments when ~'a lot of the things i want to output are similar'"


def greet(*names)
  names.each { |name| puts "Hello, #{name}!" }
end

greet("Alice", "Bob", "Carol") # Outputs: Hello, Alice! Hello, Bob! Hello, Carol!








## hashes
screen ||= {0, 0, 720, 1280} # error
screen ||= {x: 0, y: 0, h: 720, w: 1280} # hashes need keys


## arrays







# structs
Person = Struct.new(:name, :age, :job)
john = Person.new("John Doe", 30, "Engineer")
puts john.name, john.age, john.job
john.age = 31



Person = Struct.new(:name, :age) do
  def birthday
    self.age += 1
  end
end

john = Person.new("John", 30)
john.birthday
puts john.age  # Outputs: 31
  # can add methods?? so.. it's a class..?





# classes

## anonymous
ghost_class = Class.new do
  def hello
    "Hello from the ghost class!"
  end
end

obj = ghost_class.new
puts obj.hello  # Outputs: Hello from the ghost class!
  # ghost class aka eigenclass aka anonymous class
  
  
str = "hello"
def str.shout
  upcase + "!!!"
end
puts str.shout  # Outputs: HELLO!!!
  # singleton method (per-object basis)
  # wow... this is interesting, and made really really simple
  
  

## normal/declared
class MyClass
  class << self
    def class_method
      "This is a class method"
    end
  end
end

puts MyClass.class_method  # Outputs: This is a class method
  # singleton method
  
  
obj = "I'm unique" # can use any object..?
class << obj
  def unique_method
    "Unique method!"
  end
end

puts obj.unique_method  # Outputs: Unique method!
  # singleton class..! whoa.. 


class MyClass
  def self.class_method
    "I'm a class method"
  end

  private_class_method :class_method
end

if MyClass.method_defined?(:class_method)
  puts "Class method is defined"
else
  puts "Class method is not accessible"
end
  # so there are private methods..





# everything in an object  
**methods defined at the "top level" are defined as instance methods on Object, so they're inherited by everything.** The top-level context itself is a special instance of Object called "main"; by defining these methods with self., they become singleton methods of that top-level context (which is where DR looks for them), and they are not inherited by every other object in the system.

The "surprising outcome" is specifically that Object ends up being the owner of these methods, the effect is that you can call add with an implicit receiver (as in within an object), but that Object.new.add(4, 6), and [].add(4, 6), and Module.add(4, 6), and $gtk.add(4, 6) all also work.

def tick
  # ...
end
  # if on the top-level context, will be inherited by *everything*
  # use self to avoid this:

def self.tick
  # ...
end








# from getting started tutorial
   
args.outputs.labels << [580, 400, 'Hello World!']
  # The "<<" thing says "append this array onto the list of them at args.outputs.labels)
  
args.state.rotation ||= 0
  # shorthand for "if args.state.rotation isn't initialized, set it to zero." It's a nice way to embed your initialization code right next to where you need the variable.
  #  - amazing..!

args.state.laser.trash ||= true
  # nested field mades on-the-fly..?



# loops
# loops are quite different..
array = ["a", "b", "c", "d"]
array.each do |char|
  puts char
end  

array.each do |char, i|
  puts "index #{i}: #{char}"
end

3.times do |i|
  puts i
end

(0...4).each do |i|
  puts i
end
  # range block exclusive (three dots), excluding last number
  # 0-3, 4 matches the number of elements in an array

(0..3).each do |i|
  puts i
end
  # range block inclusive (two dots), including last number
  # 0-3
