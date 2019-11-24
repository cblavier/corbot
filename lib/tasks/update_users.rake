desc "Update list of users from Refuge"
task :update_users do
  cookie = ENV.fetch("REFUGE_COOKIE")
  csrf = ENV.fetch("REFUGE_CSRF")
  city_id = ENV.fetch("REFUGE_CITY_ID")
  puts Refuge::Client.search_users(city_id, cookie, csrf).inspect
end
