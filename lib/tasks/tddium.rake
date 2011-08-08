begin
  namespace :tddium do
    desc "redis hook"
    task :redis_hook => :environment

    desc "db hook"
    task :db_hook do
      Rake::Task['db:setup'].invoke
      Rake::Task['db:migrate'].invoke
    end
  end
end
