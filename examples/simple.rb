require 'checklist'

Checklist.checklist 'Example successful checklist' do |cl|
  cl.step('One', 'DONE') { sleep(1) }
  cl.step('Two', 'OK') { sleep(1) }
  cl.step('Three', 'YES') {  }
  cl.step('Four', 'BAAH', 'A longer description here') { }
end
