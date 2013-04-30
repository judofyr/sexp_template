module SexpTemplate
  class Template
    def initialize(scope_class, blk, options)
      @scope_class = scope_class
      
      case options[:type]
      when :sexp
        @sexp = blk.call
      else
        @sexp = parse_block(blk)
      end

      @call, @args, @body = *@sexp
    end
    
    def render(*args)
      RenderProcessor.new(*args).process(compile)
    end
    
    def compile
      @compiled ||= PreProcessor.new(@scope_class.templates, tmp).process(@body)
    end
    
    private

    def parse_block(blk)
      file, line = blk.source_location
      BlockExtractor.new(file, line).extract
    end

    def tmp
      @args.to_a.map do |arg|
        raise "Only regular variables are allowed" unless arg.type == :arg
        arg.to_a[0]
      end
    end
  end
end
