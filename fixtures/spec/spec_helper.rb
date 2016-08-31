FileUtils.rmtree('coverage')

module SimpleCov
  class DumpFormatter
    def format(result)
      json = JSON.pretty_generate(result.original_result.sort.to_h)
      path = File.join(SimpleCov.coverage_path, 'dump.json')
      File.write(path, json)
    end
  end
end

require 'simplecov/parallel'
CircleCI::Parallel.configuration.mock_mode = true
SimpleCov::Parallel.activate
SimpleCov.start do
  formatter SimpleCov::DumpFormatter
  add_filter '/spec/'
end
