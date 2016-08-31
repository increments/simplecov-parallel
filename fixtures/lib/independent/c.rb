module C
  module_function

  def foo
    if true
      puts :foo
    end
  end

  def bar
    if false
      puts :bar
    end
  end
end
