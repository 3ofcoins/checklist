# rubocop:disable Style/BlockDelimiters

require_relative '../spec_helper'

describe Checklist, '#run!' do
  subject { example_checklist }

  it 'should converge all the steps' do
    subject.run!

    expect { subject.body.steps == { 0 => 1, 1 => 1, 2 => 1, 3 => 1 } }
    expect { !subject.open? }
  end

  it 'should return the checklist itself' do
    expect { subject.run! == subject }
  end

  it 'should raise and report incomplete steps if a step bombs' do
    subject.step('five') do
      converge do
        raise Exception, 'as planned'
      end
    end
    subject.step('six') do
      converge do
        body.step(6)
      end
    end

    expect { rescuing { subject.run! }.is_a?(Exception) }
    expect { subject.body.steps == { 0 => 1, 1 => 1, 2 => 1, 3 => 1 } }
    expect { !subject.completed? }
    expect {
      subject.ui.record.include?([:incomplete, subject, subject.steps[4..5]])
    }
  end
end
