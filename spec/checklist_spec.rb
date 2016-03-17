require_relative './spec_helper'

module Checklist
  describe Checklist do
    it 'provides an environment for a list of steps' do
      sentinel = 23
      trace = []
      cl = Checklist.new 'test', ui: ui do
        let(:var1) { sentinel }
        let(:var2) { var1 * 2 }
        step 'first' do
          converge do
            sentinel = 17
            trace << :first
          end
        end

        step 'second' do
          converge do
            trace << var2
          end
        end
      end

      ui_output.truncate(0)
      cl.report
      ui_output.rewind
      report = ui_output.read
      expect { report.include? 'first' }
      expect { report.include? 'second' }
      expect { report.lines.length == 3 }

      expect { cl.name == 'test' }
      expect { cl.length == 2 }

      cl.run!

      expect { sentinel == 17 }
      expect { trace == [:first, 34] }
      expect { cl.done? }
    end

    it 'can render step templates' do
      trace = []
      ::Checklist.Step 'test' do |param|
        converge do
          trace << param
        end
      end

      Checklist.new 'test', ui: ui do
        step 'test', 4
        step 'test', 8
        step 'test', 15
        step 'test', 16
        step 'test', 23
        step 'test', 42
      end.run!

      expect { trace == [4, 8, 15, 16, 23, 42] }
    end

    it 'raises exception on failed steps and reports unfinished steps' do
      trace = []
      cl = Checklist.new 'test', ui: ui do
        step('foo')   { converge { trace << :foo } }
        step('bar')   { converge { trace << :bar } }
        step 'baz' do
          check { false }
          converge { trace << :baz }
        end
        step('quux')  { converge { trace << :quux } }
        step('xyzzy') { converge { trace << :xyzzy } }
      end

      exc = rescuing { cl.run! }
      expect { !exc.nil? }
      expect { exc.to_s == 'Cannot converge' }
      expect { trace == [:foo, :bar, :baz] }

      ui_output.rewind
      out = ui_output.read
      before, after = out.split('FAILED:')
      expect { before.include? 'foo' }
      expect { before.include? 'bar' }
      expect { before.include? 'baz' }
      expect { !before.include? 'quux' }
      expect { !before.include? 'xyzzy' }
      expect { !after.include? 'foo' }
      expect { !after.include? 'bar' }
      expect { after.include? 'baz' }
      expect { after.include? 'quux' }
      expect { after.include? 'xyzzy' }
    end
  end
end
