desc "Update list of users from Refuge"
task "corbot:update_users" do
  cookie = ENV.fetch("REFUGE_COOKIE")
  csrf = ENV.fetch("REFUGE_CSRF")
  city_id = Refuge::Locations.nantes_city_id
  users = Corbot::UserService.update_users_from_refuge(city_id, cookie, csrf)
  puts "created / updated #{users.count} users"
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
