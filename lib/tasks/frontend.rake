namespace :frontend do
  desc 'prepare for running frontend tests'
  task :prepare do
    sh 'bin/prepare-frontend.sh'
  end

  desc 'clean up after running frontend tests'
  task :clean do
    sh 'bin/clean-frontend.sh'
  end
end

namespace :spec do
  desc 'Runs frontend unit tests'
  task :frontend do
    sh 'bin/frontend-tests.sh'
  end

  namespace :frontend do
  desc 'Runs frontend unit tests with livereload'
    task :serve do
      sh 'bin/frontend-tests.sh serve'
    end
  end
end
