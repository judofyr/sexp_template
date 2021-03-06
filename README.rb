#
# SexpTemplate, Sexp as Ruby
#

puts %q{

  SexpTemplate is an Sexp template engine with replacement variables, uniquely
  generated variables and macro expansion, all expressed in pure Ruby.
  
  ~> ruby README.rb

}

$LOAD_PATH << 'lib'
require 'sexp_template'

class Example
  include SexpTemplate
  
  template :basic do
    # Use any Ruby inside here:
    squares = (1..10).map { |x| x * x }
    
    # Variables are just like Ruby's variables, but ends with a bang.
    # They will be replaced with the Sexp given to #render:
    content!
    
    # You can place these wherever you want:
    something!.split(", ")
    Array(something!)
  end
  
  # If you create an instance:
  example = Example.new
  
  # And call #render(template, variables)
  pp example.render(:basic,
       :content => s(:send, s(:int, 1), :+, s(:args, s(:int, 2))),
       :something => s(:str, "a, b, c"))
  
  # Then the result would be the Sexp equivalent to this code:
  ###
  squares = (1..10).map { |x| x * x }
  1 + 2
  "a, b, c".split(", ")
  Array("a, b, c")
  ###
  
  puts
  puts "See? It's right above me in the terminal!"
  puts "Don't be shy, have a look! I'll wait for you..."
  puts "(Press ENTER to continue)"
  gets
  
  puts "Okay, here's uniquely generated variables:" # huh?
  puts
  
  template :gensym do |a, b, c|
    # Any block parameters will be replaced with
    # uniquely generated variables in the block:
    a = 1
    b = 2
    c = a + b
  end
  
  pp example.render(:gensym)

  ###
  __sexp_template_1 = 1
  __sexp_template_2 = 2
  __sexp_template_3 = (__sexp_template_1 + __sexp_template_2)
  ###
  
  puts
  puts "This can be useful when you don't want to mess with other variables."
  puts "# Ready for the macro expansion thing?"
  gets

  template :base do
    1 + content!
  end
  
  template :main do
    base(:content => 2)
    base(:content => content!)
  end
  
  pp example.render(:main, :content => s(:lit, 3))
  
  ###
  1 + 2
  1 + 3
  ###
  
  puts
  puts "And that's mostly it."
end

puts
puts "# Ready for the drawbacks?"
gets

class Notes
  warn "This is a little hackish ..."

  puts "... but it works on 1.9"
  puts "... as long as you follow these rules:"
  puts

  Rules = [
  
    "Keep them in files",
    "Put them directly in the class",
    "Don't meta-program them",
    "And that's mostly it",
  
  ].each { |rule| puts "* #{rule}" }
end

puts
puts "And that's mostly it."

# pretty printing please!
BEGIN { require 'pp'; require 'ast/sexp'; include AST::Sexp }  

