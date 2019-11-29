desc "Update list of users from Refuge"
task "corbot:update_users" do
  city_id = Refuge::Locations.nantes_city_id
  users = Corbot::UserService.update_users_from_refuge(city_id)
  puts "created / updated #{users.count} users"
  Rake::Task["corbot:republish"].execute
end

desc "Publish home pages"
task "corbot:republish" do
  republished = Slack::PagePublisher.republish_user_home_pages()
  puts "republished #{republished} pages"
end

desc "Publish home pages"
task "corbot:republish_admins" do
  republished = Slack::PagePublisher.republish_admin_home_pages()
  puts "republished #{republished} pages"
end

desc "Refresh user presence from Refuge"
task "corbot:refresh_presence" do
  Corbot::UserService.refresh_presence()
  Rake::Task["corbot:republish"].execute
end
