namespace :tddium do
  desc "tddium environment db setup task"
  task :db_hook do
    Rake::Task['db:setup'].invoke
    Rake::Task['db:migrate'].invoke
  end
end
