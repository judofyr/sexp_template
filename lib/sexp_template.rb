$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'sexp_processor'

module SexpTemplate
  autoload :Template,        'sexp_template/template'
  autoload :PreProcessor,    'sexp_template/preprocessor'
  autoload :RenderProcessor, 'sexp_template/renderprocessor'
  
  CallRequired = Class.new(StandardError)
  
  module ClassMethods
    def templates
      @templates ||= {}
    end
    
    def template(name, options = {}, &blk)
      templates[name] = Template.new(self, blk, options)
    end
  end
  
  def self.included(mod)
    mod.extend ClassMethods
  end
  
  def self.copy(sexp)
    Marshal.load(Marshal.dump(sexp))
  end
  
  def initialize
    super
    @sexp_template_tmpid = 0
  end
  
  def render(name, options = {})
    self.class.templates[name].render(self, options)
  end
  
  def gensym
    :"__sexp_template_#{@sexp_template_tmpid += 1}"
  end
end