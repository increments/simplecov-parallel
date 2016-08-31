require 'dependent/a'

module B
  module_function

  def foo
    2.times do
      A.foo
    end
  end

  def bar
    2.times do
      A.bar
    end
  end
end
