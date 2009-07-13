$:.unshift File.dirname(__FILE__) + '/../lib/'

require 'rubygems'
require 'sexp_template'

class Andand < SexpProcessor
  include SexpTemplate
  
  def initialize
    super
    self.require_empty = false
  end
  
  template :andand do |tmp|
    (tmp = receiver!) && tmp.message!
  end
  
  # foo.andand.bar
  def process_call(exp)
    receiver, message = extract_andand(exp)
    
    if receiver && message
      render :andand, :receiver => receiver, :message => message
    else
      exp
    end
  end
  
  # foo.andand.bar { }
  def process_iter(exp)
    type = exp.shift
    call = exp.shift
    args = process(exp.shift)
    content = process(exp.shift)
    
    receiver, message = extract_andand(call)
    
    if receiver && message
      message = s(:iter, message, args, content)
      render :andand, :receiver => receiver, :message => message
    else
      s(type, process(call), args, content)
    end
  end
  
  def extract_andand(exp)
    if matches_andand?(exp[1])
      [exp[1][1], s(:call, nil, exp[2], process(exp[3]))]
    end
  end
  
  def matches_andand?(exp)
    exp and
    exp[0] == :call and
    exp[2] == :andand
  end
end

if $0 == __FILE__
  require 'ruby_parser'
  require 'ruby2ruby'
  require 'pp'
  
  source = <<-EOF
    foo.andand.bar
    foo.andand.bar(1, 2, 3) do
      123
    end
  EOF
  sexp = Andand.new.process(RubyParser.new.parse(source)) 
  puts "SEXP:"
  pp sexp
  puts "CODE:"
  puts Ruby2Ruby.new.process(sexp)
end

