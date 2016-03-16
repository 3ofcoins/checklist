require_relative './spec_helper'

require 'stringio'

module Checklist # rubocop:disable Metrics/ModuleLength
  class Step
    public :check!
  end

  describe Step do
    describe '#initialize' do
      it 'takes a name and a block' do
        step = Step.new('A Name', ui: ui) { converge {} }
        expect { step.name == 'A Name' }
        expect { rescuing { Step.new('.', ui: ui) }.is_a?(Exception) }
      end

      it 'takes a block that initializes the step' do
        step = Step.new 'A Name', ui: ui do
          check { true }
          expect 4, 8, 15, 16, 23, 42
          converge {}
        end

        expect { step.name == 'A Name' }
        expect { rescuing { Step.new('.', ui: ui) { bar } }.is_a?(NameError) }
      end
    end

    describe 'definition API' do
      def step(&block)
        Step.new('.', ui: ui) do
          converge {}
          instance_exec(&block) if block_given?
        end
      end

      describe '#check' do
        it 'requires either a block or a question' do
          expect { rescuing { step { check } }.is_a?(ArgumentError) }
          expect { rescuing { step { check {} } }.nil? }
          expect { rescuing { step { check 'bar?' } }.nil? }
          expect { rescuing { step { check('foo?') {} } }.is_a?(ArgumentError) }
        end

        it 'cannot be run after #initialize' do
          st = step
          expect { rescuing { st.check {} }.is_a?(RuntimeError) }
        end
      end

      describe '#expect' do
        it 'takes either some values or a block' do
          expect { rescuing { step { expect } }.is_a?(ArgumentError) }
          expect { rescuing { step { expect('foo') } }.nil? }
          expect { rescuing { step { expect('foo', 'bar') } }.nil? }
          expect { rescuing { step { expect {} } }.nil? }
          expect { rescuing { step { expect('foo') {} } }.is_a?(ArgumentError) }
        end

        it 'cannot be run after #initialize' do
          st = step
          expect { rescuing { st.expect {} }.is_a?(RuntimeError) }
        end
      end

      describe '#converge' do
        it 'requires a block' do
          expect { rescuing { step { converge } }.is_a?(ArgumentError) }
          expect { rescuing { step { converge { bar } } }.nil? }
        end

        it 'cannot be run after #initialize' do
          st = step
          expect { rescuing { st.converge {} }.is_a?(RuntimeError) }
        end
      end
    end

    describe '#check!' do
      def step(ui_ = ui, &block)
        Step.new '.', ui: ui_ do
          converge {}
          instance_exec(&block) if block_given?
        end
      end

      it 'returns false before converge and true after converge by default' do
        st = step
        expect { !st.check! }
        st.instance_exec { @after_converge = true }
        expect { st.check! }
      end

      it 'asks a yes/no question via UI if given as a string' do
        ui = Minitest::Mock.new
        ui.expect(:agree, true, ['Is this thing on?'])
        # ui.expect(:say, nil)

        st = step(ui) { check 'Is this thing on?' }
        expect { st.check! }
        ui.verify
      end

      it 'is taken at face value when no expectation is configured' do
        val = nil
        st = step { check { val } }

        val = true
        expect { st.check! }

        val = 1
        expect { st.check! }

        val = nil
        expect { !st.check! }

        val = false
        expect { !st.check! }
      end

      it 'is validated against list of expected values if provided' do
        val = nil
        st = step do
          expect :fred, :barney
          check { val }
        end

        val = true
        expect { !st.check! }

        val = :betty
        expect { !st.check! }

        val = :wilma
        expect { !st.check! }

        val = :fred
        expect { st.check! }

        val = :barney
        expect { st.check! }
      end

      it 'is validated against expect block if provided' do
        val = nil
        st = step do
          expect { |x| x > 100 }
          check { val }
        end

        # non-numerical values will throw a NoMethodError because they
        # lack #> method
        expect { rescuing { st.check! }.is_a?(NoMethodError) }

        val = true
        expect { rescuing { st.check! }.is_a?(NoMethodError) }

        val = :barney
        expect { rescuing { st.check! }.is_a?(ArgumentError) }

        val = 0
        expect { !st.check! }

        val = 23
        expect { !st.check! }

        val = 101
        expect { st.check! }

        val = 255
        expect { st.check! }
      end

      it 'runs the blocks with self set to provided context' do
        val = nil
        st = step do
          expect { |x| x == self[3] }
          check { self[3] = val }
        end

        val = 23
        ctx = {}
        expect { st.check!(ctx) }
        expect { ctx == { 3 => 23 } }

        val = 17
        expect { st.check!(ctx) }
        expect { ctx == { 3 => 17 } }

        ctx = []
        expect { st.check!(ctx) }
        expect { ctx == [nil, nil, nil, 17] }

        # no #[] on nil
        expect { rescuing { st.check!(nil) }.is_a?(NameError) }
      end
    end

    describe '#run!' do
      let(:ctx) { Hash.new { |h, k| h[k] = 0 } }
      it 'runs converge block once in context if no check' do
        st = Step.new '.', ui: ui do
          converge { self[:converged] += 1 }
        end
        expect { !st.done? }
        st.run!(ctx)
        expect { st.done? }
        expect { ctx == { converged: 1 } }
      end

      it 'does not converge if check is true' do
        st = Step.new '.', ui: ui do
          check { self[:checked] += 1 }
          converge { self[:converged] += 1 }
        end
        expect { !st.done? }
        st.run!(ctx)
        expect { st.done? }
        expect { ctx == { checked: 1 } }
      end

      it 'rechecks after converge' do
        st = Step.new '.', ui: ui do
          check { self[:checked] += 1 }
          converge { self[:converged] += 1 }
          expect 2
        end
        expect { !st.done? }
        st.run!(ctx)
        expect { st.done? }
        expect { ctx == { checked: 2, converged: 1 } }
      end

      it 'raises an exception if recheck fails' do
        st = Step.new '.', ui: ui do
          check { self[:checked] += 1 }
          converge { self[:converged] += 1 }
          expect 5
        end
        expect { !st.done? }
        expect { rescuing { st.run!(ctx) }.is_a?(RuntimeError) }
        expect { !st.done? }
        expect { ctx == { checked: 2, converged: 1 } }
      end

      it 'rechecks until it succeeds if :keep_on_trying provided' do
        st = Step.new '.', ui: ui, keep_on_trying: true do
          check { self[:checked] += 1 }
          converge { self[:converged] += 1 }
          expect { |v| v > 10 }
        end
        expect { !st.done? }
        st.run!(ctx)
        expect { st.done? }
        expect { ctx == { checked: 11, converged: 10 } }
      end
    end

    describe '.define_template & .render_template' do
      it 'defines a parameterized step template that can be rendered later' do
        val = nil
        Step.define_template 'foo' do |param|
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
end
