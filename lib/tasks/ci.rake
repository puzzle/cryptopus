# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

namespace :ci do
  desc 'Clear logs'
  task clear_logs: 'log:clear'

  desc 'Runs rubocop'
  task rubocop: 'rubocop'

  desc 'Runs brakeman'
  task brakeman: 'brakeman'

  desc 'Runs prepare frontend'
  task frontend_prepare: 'frontend:prepare'

  desc 'Runs frontend specs'
  task frontend_specs: 'spec:frontend'

  desc 'Runs spec'
  task spec: 'spec'

end

namespace :nightly do
  desc 'Runs E2E'
  task e2e: 'spec:system:lenient'
end

desc 'Runs all ci tasks'
task ci_steps: [
  'ci:clear_logs',
  'ci:rubocop',
  'ci:brakeman',
  'ci:frontend_prepare',
  'ci:frontend_specs',
  'ci:spec',
  'nightly:e2e'
]