require 'simplecov/parallel'

module SimpleCov
  RSpec.describe Parallel do
    around do |example|
      original_env = ENV.to_h
      example.run
      ENV.replace(original_env)
    end

    describe '.activate' do
      context 'on CircleCI' do
        before do
          ENV['CIRCLECI'] = 'true'
        end

        let(:adapter_class) do
          Parallel::Adapter::CircleCI
        end

        let(:adapter) do
          instance_double(adapter_class)
        end

        it 'activates Adapter::CircleCI' do
          expect(adapter_class).to receive(:new).and_return(adapter)
          expect(adapter).to receive(:activate)
          Parallel.activate
        end
      end

      context 'in other environment' do
        before do
          ENV.delete('CIRCLECI')
        end

        it 'does nothing' do
          Parallel::Adapter::Base.all_adapters.each do |adapter_class|
            expect(adapter_class).not_to receive(:new)
          end

          Parallel.activate
        end
      end
    end

    describe '.activate!' do
      context 'on CircleCI' do
        before do
          ENV['CIRCLECI'] = 'true'
        end

        let(:adapter_class) do
          Parallel::Adapter::CircleCI
        end

        let(:adapter) do
          instance_double(adapter_class)
        end

        it 'activates Adapter::CircleCI' do
          expect(adapter_class).to receive(:new).and_return(adapter)
          expect(adapter).to receive(:activate)
          Parallel.activate!
        end
      end

      context 'in other environment' do
        before do
          ENV.delete('CIRCLECI')
        end

        it 'raises error' do
          expect { Parallel.activate! }
            .to raise_error(/No SimpleCov::Parallel adapter is available/)
        end
      end
    end
  end
end
