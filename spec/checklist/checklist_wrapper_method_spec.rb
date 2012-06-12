require 'spec_helper'

describe Checklist, '.checklist' do
  let(:ui) { double('UI').stub_checklist_ui }

  it "yields a Checklist instance" do
    Checklist.checklist 'Test', :ui => ui do |cl|
      cl.should be_instance_of Checklist
    end
  end

  it "runs a checklist defined within the block" do
    tt = double("tracker")
    tt.should_receive(:first).once.ordered
    tt.should_receive(:second).once.ordered
    tt.should_receive(:third).once.ordered

    Checklist.checklist "A sample checklist", :ui => ui do |cl|
      cl.step('first', 'done') { tt.first }
      cl.step('second', 'ok')  { tt.second }
      cl.step('third', 'fine') { tt.third }
    end
  end
end
