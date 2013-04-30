require 'parser'
require 'parser/ruby19'

module SexpTemplate
  class BlockExtractor < Parser::AST::Processor
    def initialize(file, line)
      @file = file
      @line = line
    end

    def extract
      node = Parser::Ruby19.parse(File.binread(@file))
      catch(:code) do
        process(node)
        nil
      end
    end

    def on_block(node)
      if node.source_map.expression.end.line >= @line
        throw :code, node
      end
      super
    end
  end
end

