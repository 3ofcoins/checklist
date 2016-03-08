require_relative '../spec_helper'

describe Checklist, '#run!' do
  subject { example_checklist }

  it "should execute all the steps" do
    subject.run!

    expect { subject.body.steps == { 0 => 1, 1 => 1, 2 => 1, 3 => 1 } }
    expect { !subject.open? }
  end

  it 'should return the checklist itself' do
    expect { subject.run! == subject}
  end

  it 'should raise and report incomplete steps if a step bombs' do
    subject.step('five', 'bomb') do
      raise Exception, 'as planned'
      body.step(5)
    end
    subject.step('six', 'done', 'a description') { body.step(6) }

    expect { rescuing { subject.run! }.is_a?(Exception) }
    expect { subject.body.steps == { 0 => 1, 1 => 1, 2 => 1, 3 => 1 } }
    expect { !subject.completed? }
    expect { subject.ui.record.include?([:incomplete, subject, subject.steps[4..5]])}
   end
end
