require 'simplecov/parallel/adapter/base'

module SimpleCov
  module Parallel
    module Adapter
      # @api private
      class CircleCI < Base
        def self.available?
          ENV.key?('CIRCLECI')
        end

        def activate
          require 'circleci/parallel'
          require 'fileutils'

          SimpleCov.command_name("#{SimpleCov.command_name} #{current_node.name}")

          SimpleCov.at_exit do
            puts 'Merging SimpleCov result into the master node...'
            export_slave_node_result
            join_nodes_and_merge_slave_node_results
            merge_and_format_master_node_result
          end
        end

        private

        def export_slave_node_result
          return if current_node.master?

          # Export result to coverage/.resultset.json
          # https://github.com/colszowka/simplecov/blob/v0.12.0/lib/simplecov.rb#L89
          raise 'SimpleCov.use_merging must be set to true' unless SimpleCov.use_merging
          SimpleCov.result

          FileUtils.copy(
            SimpleCov::ResultMerger.resultset_path,
            ::CircleCI::Parallel.local_data_dir
          )
        end

        def join_nodes_and_merge_slave_node_results
          ::CircleCI::Parallel.configuration.after_download do
            merge_slave_node_results
          end

          ::CircleCI::Parallel.join
        end

        def merge_and_format_master_node_result
          return unless current_node.master?

          # Invoking `SimpleCov.result` here merges the master node data into the slave node data.
          # `SimpleCov.result.format!` is the default behavior of at_exit:
          # https://github.com/colszowka/simplecov/blob/v0.12.0/lib/simplecov/configuration.rb#L172
          SimpleCov.result.format!
        end

        def merge_slave_node_results
          Dir.glob('node*') do |node_dir|
            results = load_results_from_dir(node_dir)
            merge_and_save_results(results)
          end
        end

        def load_results_from_dir(dir)
          with_changing_resultset_path(dir) do
            SimpleCov::ResultMerger.results
          end
        end

        def merge_and_save_results(results)
          results.each { |result| SimpleCov::ResultMerger.store_result(result) }
        end

        def with_changing_resultset_path(dir)
          # Actually we don't want to do this hack but changing resultset_path by modifying
          # SimpleCov.root and SimpleCov.coverage_dir does not work well because .root is used in
          # the root filter, which is invoked from SimpleCov::Result#initialize.
          # https://github.com/colszowka/simplecov/blob/v0.12.0/lib/simplecov/defaults.rb#L9
          method_stasher = MethodStasher.new(SimpleCov::ResultMerger, :resultset_path)
          method_stasher.stash

          SimpleCov::ResultMerger.define_singleton_method(:resultset_path) do
            File.join(dir, '.resultset.json')
          end

          begin
            yield
          ensure
            method_stasher.pop
          end
        end

        def current_node
          ::CircleCI::Parallel.current_node
        end

        MethodStasher = Struct.new(:object, :method_name) do
          def stash
            @original_method = object.method(method_name)
            klass.__send__(:undef_method, method_name)
          end

          def pop
            if klass.__send__(:method_defined?, method_name)
              klass.__send__(:undef_method, method_name)
            end

            klass.__send__(:define_method, method_name, @original_method)
          end

          private

          def klass
            object.singleton_class
          end
        end
      end
    end
  end
end
