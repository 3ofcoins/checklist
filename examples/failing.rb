require 'checklist'

Checklist.checklist 'Example failing checklist' do |cl|
  cl.step('One', 'DONE') { sleep(1) }
  cl.step('Two', 'OK') { sleep(1) }
  cl.step('Three', 'NO') { raise RuntimeError }
  cl.step('Four', 'BAAH', 'A longer description here') { }
end
