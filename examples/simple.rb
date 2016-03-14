require 'checklist'

cl = Checklist::Checklist.new 'Example successful checklist' do
  step 'One' do
    converge { puts '1?' }
  end

  step 'Two' do
    converge { puts '2?' }
  end

  step 'Three' do
    converge { puts '3?' }
  end

  step 'Four' do
    converge { puts '4?' }
  end
end

cl.run!

cl.report
