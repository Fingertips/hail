module Kernel
  mattr_accessor :allow_backtick
  self.allow_backtick = false
  
  alias original_backtick `
  
  def `(*args)
    if allow_backtick
      original_backtick(*args)
    else
      raise RuntimeError, "You're trying to do a system call, which is probably not a very good idea in a test."
    end
  end
end