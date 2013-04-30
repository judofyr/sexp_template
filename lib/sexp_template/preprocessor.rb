require 'parser/ast/processor'
require 'ast/sexp'

module SexpTemplate
  class PreProcessor < Parser::AST::Processor
    include AST::Sexp

    def initialize(templates, tmp)
      super()
      @tmp = tmp
      @templates = templates
    end

    def matches_variable?(name, args)
      args.length == 0 and
      name.to_s[-1] == ?! and
      name.to_s[0..-2].to_sym
    end

    def matches_template?(name, args)
      args.length == 1 and
      args[0].type == :hash and
      @templates[name]
    end

    def on_send(node)
      node = super(node)
      receiver, name, *args = *node
      if var = matches_variable?(name, args)
        s(:sexp_template, :variable, var, node)
      elsif template = matches_template?(name, args)
        s(:sexp_template, :template, template, args[0], node)
      else
        node
      end
    end
    
    def matches_tmp?(name)
      @tmp.include?(name)
    end

    def on_lvasgn(node)
      node = super(node)

      name, *rest = *node
      if matches_tmp?(name)
        s(:sexp_template, :tmp, name, node)
      else
        node
      end
    end

    alias on_lvar on_lvasgn
  end
end
