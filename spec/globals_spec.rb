require_relative './spec_helper'

module Checklist
  describe Checklist do
    describe '.new' do
      it 'is an alias to Checklist::Checklist.new' do
        passed = false
        ::Checklist.new 'test', ui: ui do
          step('.') { converge { passed = true } }
        end.run!
        expect { passed }
      end
    end

    describe '.Step' do
      it 'defines new step template' do
        val = nil
        ::Checklist.Step 'foo' do |param|
          converge do
            val = "#{param}!"
          end
        end

        st1 = Step.render_template 'foo', { ui: ui }, 'fred'
        expect { st1.name == 'foo' }
        st1.run!
        expect { val == 'fred!' }

        st2 = Step.render_template 'foo', { ui: ui }, 'barney'
        expect { st2.name == 'foo' }
        st2.run!
        expect { val == 'barney!' }
      end
    end
  end

  describe ObjectExt do
    describe '.Checklist' do
      it 'defines a checklist template or renders one' do
        trace = []
        Object.new.instance_exec do
          Checklist 'test' do |param|
            step('one') { converge { trace << "#{param}/1" } }
            step('two') { converge { trace << "#{param}/2" } }
          end
        end

        Checklist('test', { ui: ui }, 'fred').run!
        Checklist('test', { ui: ui }, 'barney').run!

        expect { trace == %w(fred/1 fred/2 barney/1 barney/2) }
      end

      it 'refuses to accept arguments with a block' do
        expect do
          rescuing do
            Object.new.instance_exec do
              Checklist('foo', 'bar', 'baz') { quux? }
            end
          end.is_a?(ArgumentError)
        end
      end
    end
  end
end
