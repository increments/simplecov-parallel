[![Gem Version](https://badge.fury.io/rb/simplecov-parallel.svg)](http://badge.fury.io/rb/simplecov-parallel)
[![Dependency Status](https://gemnasium.com/increments/simplecov-parallel.svg)](https://gemnasium.com/increments/simplecov-parallel)
[![CircleCI](https://circleci.com/gh/increments/simplecov-parallel.svg?style=shield)](https://circleci.com/gh/increments/simplecov-parallel)
[![Code Climate](https://codeclimate.com/github/increments/simplecov-parallel/badges/gpa.svg)](https://codeclimate.com/github/increments/simplecov-parallel)

# SimpleCov::Parallel

**SimpleCov::Parallel** is a [SimpleCov](https://github.com/colszowka/simplecov) extension for parallelism support.
It automatically transfers each node coverage data to a single master node and merges the data.
Currently only [CircleCI parallelism](https://circleci.com/docs/parallelism/) is supported.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'simplecov-parallel'
```

And then execute:

```bash
$ bundle install
```

## Usage

You just need to invoke `SimpleCov::Parallel.activate` before start tracking coverage:

```ruby
# spec/spec_helper.rb
require 'simplecov/parallel'
SimpleCov::Parallel.activate
SimpleCov.start
```

SimpleCov::Parallel automatically detects the best parallelism support for the current environment.

You can use any formatter transparently
since SimpleCov::Parallel merges the results into `SimpleCov.result`,
which is a basic API of SimpleCov.

## CircleCI

When using SimpleCov::Parallel on CircleCI:

* [Add `parallel: true`](https://circleci.com/docs/parallel-manual-setup/)
  to the test command (e.g. `rspec`) in your `circle.yml`.
* [Set up parallelism](https://circleci.com/docs/setting-up-parallelism/)
  for your project from the CircleCI web console.

```yaml
# circle.yml
test:
  override:
    - bundle exec rspec:
        parallel: true
        files:
          - spec/**/*_spec.rb
```

The SimpleCov formatter will be executed only on the first node (where `CIRCLE_NODE_INDEX` is `0`).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
