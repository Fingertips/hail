module StdOutReceptor
  def capturing_stdout
    original_stdout = $stdout
    $stdout = Receptor.instance
    yield
  ensure
    $stdout = original_stdout
  end
  
  def stdout_lines
    Receptor.instance.message.map { |call| call[1] }
  end
end