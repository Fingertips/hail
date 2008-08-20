module Kernel
  mattr_accessor :allow_system
  self.allow_system = false
  
  alias original_system system
  
  def system(*args)
    if allow_system
      original_system(*args)
    else
      raise RuntimeError, "You're trying to do a system call, which is probably not a very good idea in a test."
    end
  end
end