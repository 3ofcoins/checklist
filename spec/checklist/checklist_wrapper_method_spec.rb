require 'spec_helper'

describe Checklist, '.checklist' do
  it "yields a Checklist instance" do
    Checklist.checklist 'Test' do |cl|
      cl.should be_instance_of Checklist
    end
  end

  it "runs a checklist defined within the block" do
    tt = double("tracker")
    tt.should_receive(:first).once.ordered
    tt.should_receive(:second).once.ordered
    tt.should_receive(:third).once.ordered

    Checklist.checklist "A sample checklist" do |cl|
      cl.step('first', 'done') { tt.first }
      cl.step('second', 'ok')  { tt.second }
      cl.step('third', 'fine') { tt.third }
    end
  end
end
