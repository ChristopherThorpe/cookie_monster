begin
  namespace :tddium do
    task :redis_hook => :environment
    task :db_hook do
      Rake::Task['db:setup'].invoke
      Rake::Task['db:migrate'].invoke
    end
  end
end
