require "spec_helper.rb"

describe "Refuge API client" do
  let(:cookie) { ENV.fetch("REFUGE_COOKIE") }

  xit "should return profile" do
    puts Refuge.get_refuge_profile(2075, cookie)
  end

  xit "should search profiles" do
    puts Refuge.search_users(8, cookie)
  end
end
