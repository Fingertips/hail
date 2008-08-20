class Receptor
  require 'singleton'
  include Singleton
  
  attr_accessor :messages
  
  def initialize
    @messages = []
  end
  
  def respond_to?(method, include_private=false)
    true
  end
  
  def method_missing(*attrs)
    self.messages << attrs
  end
end