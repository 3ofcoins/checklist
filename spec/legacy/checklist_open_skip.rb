require_relative '../spec_helper'

describe Checklist, '#open!' do
  subject { example_checklist }

  it 'opens the checklist' do
    expect { !subject.open? }
    subject.open!
    expect { subject.open? }
    expect { subject.completed == 0 }
    expect { subject.remaining == subject.length }
  end

  it 'reports the checklist header' do
    subject.open!
    expect { subject.ui.record.include? [:header, subject] }
  end

  it 'cannot be called twice' do
    subject.open!
    expect { rescuing { subject.open! }.is_a?(RuntimeError) }
  end

  it 'prevents adding new steps' do
    subject.open!
    exc = rescuing { subject.step('one') { nil } }
    expect { exc.is_a?(RuntimeError) }
  end

  it 'returns checklist itself' do
    expect { subject.open! == subject }
  end
end
