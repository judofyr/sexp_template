module SexpTemplate
  class RenderProcessor < SexpProcessor
    def initialize(processor, options = {})
      super()
      self.auto_shift_type = true
      @processor = processor
      @options = options
      @tmpsym = Hash.new { |h, k| h[k] = @processor.gensym }
    end
    
    def process_sexp_template(exp)
      type = exp.shift
      send("st_#{type}", exp)
    end
    
    def st_local_variables(exp)
      type = exp.shift
      name = exp.shift
      name = @tmpsym[name]
      value = process(exp.shift)
      
      s(type, name, value).compact
    end
    
    def st_template(exp)
      template = exp.shift
      args = exp.shift
      args.shift # :arglist

      hash = args.shift
      hash.shift # :hash 
      
      options = {}

      until hash.empty?
        key = hash.shift
        value = hash.shift
        options[key[1]] = value
      end
      
      process(template.render(@processor, options))
    end
    
    def st_call(exp)
      name = exp.shift
      backup = exp.shift

      if var?(name)
        expand_variable(name, backup)
      else
        backup
      end
    end
    
    def process_dstr(exp)
      nexp = s(:dstr, exp.shift)
      
      until exp.empty?
        str = exp.shift
        # If we have a call inside an evstr:
        if evstr_call?(str)
          name, backup = str[1][2..-1]
          # If it happens to be a value we should replace:
          if var?(name)
            case r = replacement(name) 
            when Symbol, String, Numeric
              # If it's a number, string or symbol,
              # inject it into to the parent string
              nexp << s(:str, r.to_s)
              next
            when Sexp
              case r.sexp_type
              when :dstr
                # Inject other interpolation strings:
                car, *cdr = r.sexp_body
                nexp << s(:str, car)
                nexp.concat(cdr)
                next
              when :str
                # Inject other strings:
                nexp << r
                next
              when :nil
                # Ignore nils
                next
              end
            end
          end
        end
        # If not, simply process it:
        nexp << process(str)
      end   
      
      nexp    
    end
    
    def expand_variable(name, backup)
      exp = SexpTemplate.copy(replacement(name))

      # If the old value had a receiver:
      if backup[1]
        case exp.sexp_type
        when :call
          exp[1] = process(backup[1])
        when :iter
          exp[1][1] = process(backup[1])
        else
          raise UnsupportedNodeError, "cannot replace #{name} with #{exp.sexp_type}"
        end
      end

      # If nexp is nothing, let's do nothing:
      exp || s(:nil)
    end
    
    def evstr_call?(exp)
      exp[0] == :evstr and
      exp[1][0] == :sexp_template and
      exp[1][1] == :call
    end
    
    def var?(name)
      @options.has_key?(name)
    end
    
    def replacement(name)
      @options[name]
    end
  end
end