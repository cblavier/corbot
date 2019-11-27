desc "Update list of users from Refuge"
task "corbot:update_users" do
  cookie = ENV.fetch("REFUGE_COOKIE")
  csrf = ENV.fetch("REFUGE_CSRF")
  city_id = ENV.fetch("REFUGE_CITY_ID")
  users = Corbot::UserService.update_users_from_refuge(city_id, cookie, csrf)
  puts "created / updated #{users.count} users"

end

desc "Publish home pages"
task "corbot:republish" do
  Slack::PagePublisher.republish_user_home_pages()
end