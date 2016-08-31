module D
  module_function

  def foo(bool)
    if bool
      puts :foo
    end
  end

  def bar(bool)
    if !bool
      puts :bar
    end
  end
end
