Given /^resque is started$/ do
  CucumberExternalResqueWorker.start
end

Given "the email queue is empty" do
  CucumberExternalResqueWorker.reset_counter
  Resque.remove_queue(Resque::Mailer)
  reset_mailer
end

Given /^the eat queue is empty$/ do
  CucumberExternalResqueWorker.reset_counter
  Resque.remove_queue(Eat)
end

When "all queued jobs are processed" do
  CucumberExternalResqueWorker.process_all
end

When /^I GET to eat "([^"]*)"$/ do |arg1|
  visit "/eat/#{arg1}"
end

Then /^a new food called "([^"]*)" should have been created$/ do |arg1|
  Food.last.name.should == arg1
end

Then /^the most recent food in redis should be "([^"]*)"$/ do |arg1|
  $redis.get('most_recent_food').should == arg1
end

Then /^deleting it from the cache should succeed$/ do
  $redis.del('most_recent_food').should == 1
end


