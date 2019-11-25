require "spec_helper.rb"

describe "user_service" do
  let(:cookie) { ENV["REFUGE_COOKIE"] }
  let(:csrf) { ENV["REFUGE_CSRF"] }
  let(:city_id) { ENV["CITY_ID"] }
  let(:cassette) { "refuge_search_users_ok" }

  describe "update_users_from_refuge" do
    subject {
      VCR.use_cassette(cassette) do
        Corbot::UserService.update_users_from_refuge(city_id, cookie, csrf)
      end
    }

    it "should create all users" do
      expect { subject }.to change { Corbot::User.count }.from(0).to(67)
    end

    it "should create all users on when ran twice" do
      expect {
        subject()
        subject()
      }.to change { Corbot::User.count }.from(0).to(67)
    end
  end
end
