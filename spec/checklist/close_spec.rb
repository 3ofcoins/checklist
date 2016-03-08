# rubocop:disable Style/BlockDelimiters

require_relative '../spec_helper'

describe Checklist, '#close!' do
  subject { example_checklist }

  it 'should report checklist completion' do
    subject.open!
    subject.length.times { subject.step! }
    subject.close!
    expect { subject.ui.record.include?([:complete, subject]) }
  end

  it 'should report outstanding steps' do
    subject.open!
    2.times { subject.step! }
    subject.close!
    expect {
      subject.ui.record.include?([:incomplete, subject, subject.steps[2..3]])
    }
  end

  it 'should return outstanding steps' do
    subject.open!
    subject.step!

    rv = subject.close!
    expect { rv.is_a?(Array) }
    expect { rv.length == 3 }
    rv.each_with_index do |s, i|
      expect { s.is_a?(Checklist::Step) }
      expect { s.challenge == EXAMPLE_STEPS[i + 1][0] }
      expect { s.response == EXAMPLE_STEPS[i + 1][1] }
    end
  end

  it 'should require checklist to be open' do
    expect { rescuing { subject.close! }.is_a?(RuntimeError) }
  end
end
