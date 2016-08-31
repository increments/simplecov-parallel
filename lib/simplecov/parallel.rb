require 'simplecov'
require 'simplecov/parallel/adapter/circleci'

module SimpleCov
  # Provides parallelism support for SimpleCov.
  module Parallel
    NoAdapterAvailableError = Class.new(StandardError)

    class << self
      # Activates SimpleCov parallelism support for the current environment.
      # This modifies some SimpleCov configuration options so you should configure SimpleCov before
      # invoking this method.
      # When no adapter is available in the current environment, it does nothing.
      #
      # @example
      #   require 'simplecov/parallel'
      #   SimpleCov::Parallel.activate
      #   SimpleCov.start
      #
      # @see .activate!
      def activate
        activate!
      rescue NoAdapterAvailableError # rubocop:disable Lint/HandleExceptions
      end

      # Activates SimpleCov parallelism support for the current environment.
      # This modifies some SimpleCov configuration options so you should configure SimpleCov before
      # invoking this method.
      #
      # @raise NoAdapterAvailableError when no adapter is available in the current environment
      #
      # @example
      #   require 'simplecov/parallel'
      #   SimpleCov::Parallel.activate! if ENV['CIRCLECI']
      #   SimpleCov.start
      #
      # @see .activate!
      def activate!
        if available_adapter_classes.empty?
          raise NoAdapterAvailableError,
                'No SimpleCov::Parallel adapter is available in the current environment.'
        end

        available_adapter_classes.first.new.activate
      end

      private

      def available_adapter_classes
        Adapter::Base.all_adapters.select(&:available?)
      end
    end
  end
end
