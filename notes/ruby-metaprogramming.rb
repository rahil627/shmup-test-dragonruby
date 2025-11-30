

# what i think of when i hear meta-programming

## the dirty stuff
  - eval, class_eval, instance_eval
  
class MultiMethodClass
  [:foo, :bar, :baz].each do |method_name|
    class_eval <<-RUBY
      def #{method_name}
        puts "#{method_name} called"
      end
    RUBY
  end
end

obj = MultiMethodClass.new
obj.foo  # Outputs: foo called
obj.bar  # Outputs: bar called
obj.baz  # Outputs: baz called
  # class_eval
  
  
def evaluate_code(code, context)
  context.instance_eval(code)
end

class MyClass
  def initialize(value)
    @value = value
  end

  def get_value
    @value
  end
end

obj = MyClass.new(42)
result = evaluate_code("@value + 8", obj)
puts result  # Outputs: 50
  # instance_eval
  
  

  
  


## mix-ins
obj.extend(ModuleName)
  # mix-in module dynamically
    # wow... incredibly simple..(!)
    
    
module ClassMethods
  def class_method
    "Class method from module"
  end
end

module InstanceMethods
  def instance_method
    "Instance method from module"
  end
end

module MyModule
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end
end

class MyClass
  include MyModule
end

puts MyClass.class_method  # Outputs: Class method from module
obj = MyClass.new
puts obj.instance_method  # Outputs: Instance method from module
  # included hook used to add class methods
    #  i didn't quite understand, but it seems useful for modular coding!    
    
    
    
    
    
## class methods (functions) and attributes (data) 
class MyClass
  [:attr1, :attr2, :attr3].each do |attr|
    attr_accessor attr # doesn't have to be in top-level of a class??
  end
end

obj = MyClass.new
obj.attr1 = "Value"
puts obj.attr1  # Outputs: Value
  # dynamic attributes
    
    
class DynamicMethods
  def self.create_method(name)
    define_method(name) do # i think define_method is a keyword
    # or define_singleton_method
      "This is method #{name}"
    end
  end
end

DynamicMethods.create_method(:hello)
obj = DynamicMethods.new
puts obj.hello  # Outputs: This is method hello
  # dynamic method definition
  # i have to think about this some more..
    
    
    
class GhostMethods
  def method_missing(name, *args) # i think method_missing is a keyword
    puts "You called #{name} with #{args.inspect}"
  end
end

obj = GhostMethods.new
obj.anything_you_like(1, 2, 3)  # Outputs: You called anything_you_like with [1, 2, 3]
  # seems like for mistake handling
  
  
  
class TrackMethods
  def self.method_added(name)
    puts "New method added: #{name}"
  end

  def sample_method
    # Does something
  end
end
# Outputs: New method added: sample_method
  # method_added
    # seems good for debugging when methods are added






## DSL
class Person
  attr_accessor :name, :age

  def self.attributes(*names)
    names.each do |name|
      attr_accessor name
    end
  end

  attributes :height, :weight, :eye_color
end

john = Person.new
john.height = 180
puts john.height  # Outputs: 180
  # DSL
    # don't quite see it.. yet.
    
    
    
    
    
# other neat stuff

class DynamicCaller
  def say_hello
    "Hello!"
  end
end

obj = DynamicCaller.new
puts obj.send(:say_hello)  # Outputs: Hello!
puts obj.__send__(:say_hello)  # Outputs: Hello!
  # dynamically call methods
  
  
class MyClass
  def my_method
    puts "Original method"
  end

  alias :original_method :my_method

  def my_method
    puts "Wrapped before"
    original_method
    puts "Wrapped after"
  end
end

obj = MyClass.new
obj.my_method
# Outputs:
# Wrapped before
# Original method
# Wrapped after
  # using method aliasing for wrapping old functions
    # great for altering a function without refactoring
    
    
    
