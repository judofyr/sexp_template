module SexpTemplate
  class PreProcessor < SexpProcessor
    def initialize(processor_class, tmp)
      super()
      @tmp = tmp
      @processor_class = processor_class
    end
    
    def process_call(exp)
      type = exp.shift
      receiver = process(exp.shift)
      name = exp.shift
      args = process(exp.shift)
      
      exp = s(type, receiver, name, args)
      
      case
      when template = matches_template?(name, args)
        s(:sexp_template, :template, template, args)
      when name = matches_variable?(name, args)
        s(:sexp_template, :call, name, exp)
      else
        exp
      end 
    end
    
    def process_local_variables(exp)
      type = exp.shift
      name = exp.shift
      value = process(exp.shift)
      
      if matches_tmp?(name)
        s(:sexp_template, :local_variables, type, name, value)
      else
        s(type, name, value).compact
      end
    end
    
    alias process_lvar process_local_variables
    alias process_lasgn process_local_variables
    
    def matches_tmp?(name)
      @tmp.include?(name)
    end
    
    def matches_template?(name, args)
      (args.length == 1 or
      args[1][0]  == :hash) and
      @processor_class.templates[name]
    end
    
    def symargs?(args)
      args.length == 2 and
      args[1].sexp_type == :hash and
      args[1].sexp_body.all? { |key, value| sym?(key) }
    end
    
    def sym?(exp)
      exp.sexp_type == :lit and
      exp.sexp_body.is_a?(Symbol)
    end
    
    def matches_variable?(name, args)
      args.length == 1 and
      name.to_s[-1] == ?! and
      name.to_s[0..-2].to_sym
    end
  end
end