require_relative './step'

module Checklist
  Step 'rake' do |*tasks|
    tasks.map! { |t| Array(t) }
    @name = "rake #{tasks.map(&:first).map(&:to_s).join(' ')}"
    reenable = opts[:reenable]
    converge do
      tasks.each do |task, *args|
        task = Rake::Task[task] unless task.is_a?(Rake::Task)
        task.reenable if reenable
        feedback = "rake #{task}"
        feedback << "[#{args.map(&:to_s).join(',')}]" unless args.empty?
        $stderr.puts(feedback)
        task.invoke(*args)
      end
    end
  end
end
