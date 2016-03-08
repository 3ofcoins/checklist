require_relative '../spec_helper'

describe Checklist, '#step!' do
  subject { example_checklist }

  it 'should execute one next step and push it from remaining to completed' do
    subject.open!

    expect { subject.remaining == 4 }
    expect { subject.completed == 0 }
    expect { subject.body.steps == {} }

    subject.step!

    expect { subject.remaining == 3 }
    expect { subject.completed == 1 }
    expect { subject.body.steps[0] == 1 }

    subject.step!

    expect { subject.remaining == 2 }
    expect { subject.completed == 2 }
    expect { subject.body.steps[1] == 1 }

    subject.step!

    expect { subject.remaining == 1 }
    expect { subject.completed == 3 }
    expect { subject.body.steps[2] == 1 }

    subject.step!

    expect { subject.remaining == 0 }
    expect { subject.completed == 4 }
    expect { subject.body.steps[3] == 1 }
  end

  it 'should complete the checklist, eventually' do
    subject.open!

    subject.length.times do
      expect { !subject.completed? }
      subject.step!
    end

    expect { subject.completed? }
  end

  it 'should not be allowed when list is completed' do
    subject.open!

    subject.length.times { subject.step! }
    expect { rescuing { subject.step! }.is_a?(RuntimeError) }
  end

  it 'should be disallowed when list is not open' do
    # Look, Ma, no open!
    expect { rescuing { subject.step! }.is_a?(RuntimeError) }
  end
end
