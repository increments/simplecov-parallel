require 'simplecov/parallel/adapter/circleci'
require 'circleci/parallel'
require 'json'

module SimpleCov::Parallel
  RSpec.describe Adapter::CircleCI do
    before do
      CircleCI::Parallel.reset!
    end

    def run_rspec_on_circleci(spec_files, node_index, node_count)
      env = {
        'CIRCLECI'          => 'true',
        'CIRCLE_BUILD_NUM'  => '123',
        'CIRCLE_NODE_TOTAL' => node_count.to_s,
        'CIRCLE_NODE_INDEX' => node_index.to_s
      }
      run_rspec(spec_files, env)
    end

    def run_rspec(spec_files, env = {})
      Bundler.with_clean_env do
        Dir.chdir('fixtures') do
          ENV.update(env)
          command = %w(bundle exec rspec).concat(spec_files)
          run_command(command, silent: true)
        end
      end
    end

    def run_command(command, silent: true)
      if silent
        `#{command.join(' ')}`
      else
        system(*command)
      end
    end

    def load_simplecov_result
      json = File.read('fixtures/coverage/dump.json')
      JSON.parse(json).freeze
    end

    context 'when each node coverage does not overlap' do
      subject(:merged_result) do
        spec_files_by_node = {
          2 => ['spec/independent/c_spec.rb'],
          1 => ['spec/independent/a_spec.rb', 'spec/independent/d_spec.rb'],
          0 => ['spec/independent/b_spec.rb']
        }

        spec_files_by_node.each do |node_index, spec_files|
          run_rspec_on_circleci(spec_files, node_index, spec_files_by_node.count)
        end

        load_simplecov_result
      end

      let(:single_run_result) do
        run_rspec(['spec/independent'], 'CIRCLECI' => nil)
        load_simplecov_result
      end

      it 'merges all the results so that the merged result is equal to the result by single run' do
        expect(merged_result).to eq(single_run_result)
      end
    end

    context 'when each node coverage overlaps' do
      subject(:merged_result) do
        spec_files_by_node = {
          '2' => ['spec/dependent/c_spec.rb'],
          '1' => ['spec/dependent/a_spec.rb', 'spec/dependent/d_spec.rb'],
          '0' => ['spec/dependent/b_spec.rb']
        }

        spec_files_by_node.each do |node_index, spec_files|
          run_rspec_on_circleci(spec_files, node_index, spec_files_by_node.count)
        end

        load_simplecov_result
      end

      let(:single_run_result) do
        run_rspec(['spec/dependent'], 'CIRCLECI' => nil)
        load_simplecov_result
      end

      def without_key(hash, key)
        hash.reject { |k| k == key }
      end

      it 'merges all the results by adding each line execution count' do
        file_a, file_a_coverage = merged_result.find { |file, _| file.end_with?('/a.rb') }
        expect(without_key(merged_result, file_a)).to eq(without_key(single_run_result, file_a))
        expect(file_a_coverage).to eq([2, 2, nil, 2, 3, nil, nil, 2, 0, nil, nil])
      end
    end
  end
end
