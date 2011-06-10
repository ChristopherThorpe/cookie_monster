require 'resque/tasks'
include Rake::DSL

task "resque:setup" => :environment
