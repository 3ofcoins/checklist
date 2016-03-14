require_relative '../spec_helper'

describe Checklist, '.checklist' do
  let(:ui) { Checklist::Spec::UI.new }

  it 'yields a Checklist instance' do
    Checklist.checklist 'Test', ui: ui do |cl|
      expect { cl.is_a?(Checklist::Checklist) }
    end
  end

  it 'runs a checklist defined within the block' do
    record = []
    Checklist.checklist 'A sample checklist', ui: ui do |cl|
      cl.step('first')  { converge { record << 1 } }
      cl.step('second') { converge { record << 2 } }
      cl.step('third')  { converge { record << 3 } }
    end
    expect { record == [1, 2, 3] }
  end
end
