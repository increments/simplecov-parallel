source 'https://rubygems.org'

gemspec

# simplecov 0.12.0 has a bug in result merger and the bugfix is not yet released.
# https://github.com/colszowka/simplecov/pull/513
gem 'simplecov', github: 'colszowka/simplecov'

group :development, :test do
  gem 'rake', '~> 11.0'
  gem 'rspec', '~> 3.5'
  gem 'rubocop', '~> 0.42'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.6'
end
