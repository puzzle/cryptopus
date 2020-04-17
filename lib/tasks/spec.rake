# frozen_string_literal: true

if Rake::Task.task_defined?('spec') # only if current environment knows rspec
  Rake::Task['spec'].actions.clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--tag ~type:system'
  end
  
  Rake::Task['spec:system'].actions.clear
  namespace :spec do
    RSpec::Core::RakeTask.new(:system) do |t|
      t.pattern = './spec/system/**/*_spec.rb'
      t.rspec_opts = '--tag type:system'
    end

    namespace :system do
      desc 'Prepare frontend before running system tests'
      task :prepare do
      end

      desc 'Run system tests at most three times to gracefully handle flaky specs'
      task :lenient do
        ENV['SPEC_NO_EXCLUDES'] = 'true'

        puts "\nFIRST ATTEMPT\n"
        Rake::Task['spec:system:start'].invoke

        unless $CHILD_STATUS.exitstatus.zero?
          puts "\nSECOND ATTEMPT \n"
          Rake::Task['spec:system:retry'].invoke

          unless $CHILD_STATUS.exitstatus.zero?
            puts "\nLAST ATEMPT\n"
            Rake::Task['spec:system:last'].invoke
          end
        end
      end

      desc 'Clean up frontend files after system tests'
      task :cleanup do
      end

      RSpec::Core::RakeTask.new('start') do |t|
        t.pattern = './spec/system/**/*_spec.rb'
        t.fail_on_error = false # don't stop the whole run
        t.rspec_opts = '--tag type:system'
      end

      RSpec::Core::RakeTask.new('retry') do |t|
        t.fail_on_error = false # don't stop the whole run
        t.rspec_opts = '--only-failures'
      end

      RSpec::Core::RakeTask.new('last') do |t|
        t.fail_on_error = true # do fail the run
        t.rspec_opts = '--only-failures'
      end
    end
  end
end
