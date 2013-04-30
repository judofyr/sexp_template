require 'parser/ast/processor'

module SexpTemplate
  class RenderProcessor < Parser::AST::Processor
    def initialize(scope, options = {})
      super()
      @scope = scope
      @options = options
      @tmpsym = Hash.new { |h, k| h[k] = @scope.gensym }
    end

    def on_sexp_template(node)
      type, *args = *node
      send("st_#{type}", *args)
    end
    
    def variable?(name)
      @options.has_key?(name)
    end
    
    def replacement(name)
      @options[name]
    end

    def st_variable(name, previous)
      if variable?(name)
        replacement(name)
      else
        process(previous)
      end
    end

    def st_tmp(name, node)
      node = process(node)
      _, *rest = *node
      name = @tmpsym[name]
      node.updated(nil, [name, *rest])
    end

    def st_template(template, hash, node)
      options = {}
      hash.to_a.each do |pair|
        key, value = *pair
        return process(node) unless key.type == :sym
        options[key.to_a[0]] = process(value)
      end
      template.render(@scope, options)
    end
  end
end
