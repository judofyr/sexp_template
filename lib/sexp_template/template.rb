module SexpTemplate
  class Template
    attr_accessor :sexp
    attr_reader :processor
    
    def initialize(processor, blk, options)
      @processor = processor
      
      case options[:type]
      when :sexp
        @sexp = blk.call
      else
        @sexp = load(blk)
      end
      
      @code = @sexp[3]
      @args = load_args(@sexp[2])
    end
    
    def render(*args)
      RenderProcessor.new(*args).process(compile)
    end
    
    def compile
      SexpTemplate.copy(compile!)
    end
    
    def name
      @templates.index(self)
    end
    
    private

    def compile!
      @compiled ||= PreProcessor.new(@processor, @args).process(@code)
    end
    
    def load_args(exp)
      return [] unless exp.is_a?(Sexp)
      
      case exp.sexp_type
      when :lasgn
        exp.sexp_body
      when :masgn
        exp[1].sexp_body.map { |e| e[1] }
      end
    end
    
    def load(blk)
      if Proc.instance_methods.include?(:source_location)
        require 'ruby_parser'
        alias load load_by_source_location
      else
        require 'parse_tree'
        alias load load_by_parse_tree
      end
      
      load(blk)
    end
    
    def load_by_source_location(blk)
      raise "SexpTemplate currently only works with ParseTree."
    end
    
    def load_by_parse_tree(blk, *args)
      pt = ParseTree.new(false)
      sexp = pt.parse_tree_for_proc(blk)
      Unifier.new.process(sexp)
    end
  end
end