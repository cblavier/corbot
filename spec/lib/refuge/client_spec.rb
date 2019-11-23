require "spec_helper.rb"

describe "Refuge API client" do
  let(:cookie) { ENV.fetch("REFUGE_COOKIE") }
  let(:csrf) { ENV.fetch("REFUGE_CSRF") }

  describe "user profile" do
    let(:cassette) { "refuge_profile_#{user_id}" }

    let(:subject) {
      VCR.use_cassette(cassette) do
        Refuge::Client.get_refuge_profile(user_id, cookie)
      end
    }

    context "with correct id" do
      let(:user_id) { 2075 }

      it "should return profile" do
        body = subject()
      end
    end

    context "with unknown id" do
      let(:user_id) { "unknown" }

      xit "should raise not_found error" do
        body = subject()
      end
    end
  end

  xit "should search profiles" do
    puts Refuge.search_users(8, cookie, csrf)
  end
end
