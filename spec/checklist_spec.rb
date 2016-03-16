require_relative './spec_helper'

module Checklist
  describe Checklist do
    it 'provides an environment for a list of steps' do
      sentinel = 23
      trace = []
      cl = ::Checklist.checklist 'test', ui: ui do
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

      expect { cl.name == 'test' }
      expect { cl.length == 2 }

      cl.run!

      expect { sentinel == 17 }
      expect { trace == [:first, 34] }
      expect { cl.done? }
    end
  end
end
