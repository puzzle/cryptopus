# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

desc 'Runs the taks for a commit build'
task ci: ['log:clear',
          'rubocop',
          'geo:fetch',
          'frontend:prepare',
          'spec:frontend',
          'db:test:prepare',
          'spec']

namespace :ci do
  desc 'Runs the additional tasks for the nightly or manual build'
  task nightly: ['brakeman',
                 'spec:system:lenient']

end
