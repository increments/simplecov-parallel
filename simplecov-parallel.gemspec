# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simplecov/parallel/version'

Gem::Specification.new do |spec|
  spec.name          = 'simplecov-parallel'
  spec.version       = SimpleCov::Parallel::Version.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']

  spec.summary       = 'SimpleCov extension for parallelism support'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/increments/simplecov-parallel'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'circleci-parallel', '~> 0.5'
  # simplecov 0.12.0 has a bug in result merger.
  # https://github.com/colszowka/simplecov/pull/513
  spec.add_runtime_dependency 'simplecov', '~> 0.15'

  spec.add_development_dependency 'bundler', '~> 1.12'
end
