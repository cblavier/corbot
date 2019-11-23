require "spec_helper.rb"

describe "Refuge API client" do
  let(:cookie) { ENV["REFUGE_COOKIE"] }
  let(:csrf) { ENV["REFUGE_CSRF"] }

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
        expect(subject['first_name']).to eq("François")
      end
    end

    context "with unknown id" do
      let(:user_id) { "unknown" }

      it "should raise not_found error" do 
        expect{subject}.to raise_error "redirected (not found?)"
      end 
    end

    context "with bad cookie" do
      let(:user_id) { "unauthorized" }
      let(:cookie) { "wrong" }

      it "should raise not_found error" do 
        expect{subject}.to raise_error "unauthorized"
      end 
    end
  end

  xit "should search profiles" do
    puts Refuge.search_users(8, cookie, csrf)
  end
end
