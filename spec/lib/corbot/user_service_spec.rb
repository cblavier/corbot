require "spec_helper"

describe Corbot::UserService do
  let(:city_id) { Refuge::Locations.nantes_city_id }
  let(:cassette) { "refuge/search_users_ok" }

  describe "update_users_from_refuge" do
    subject do
      VCR.use_cassette(cassette) do
        described_class.update_users_from_refuge(city_id, max_search_users_page: 1)
      end
    end

    it "should create all users" do
      expect { subject }.to change { Corbot::User.count }.from(0).to(68)
      Corbot::User.all.each do |user|
        expect(user.removed).to be false
      end
    end

    it "should create all users on when ran twice" do
      expect do
        subject
        subject
      end.to change { Corbot::User.count }.from(0).to(68)
    end

    it "should delete old users" do
      user = create_user(424_242)
      expect { subject }.to change { Corbot::User.count }.from(1).to(69).and change { user.reload.removed }.from(false).to(true)
    end
  end

  describe "users_without_slack_id" do
    subject { described_class.users_without_slack_id }

    context "with no users" do
      let(:users) { [] }

      it "should return an empty array" do
        expect(subject).to be_empty
      end
    end

    context "with some unbound users" do
      let!(:users) do
        3.times.map { |i| create_user(i, slack_user_id: i) } + 2.times.map { |i| create_user(i) }
      end

      it "should return them" do
        expect(subject).to satisfy { |users| users.length == 2 }
      end
    end
  end

  describe "bind user" do
    let(:user) { create_user("42") }
    let(:slack_user_id) { "37" }
    subject { described_class.bind_user(user.refuge_user_id, slack_user_id) }

    it "should bind slack_user_id and bound_at" do
      expect { subject }.to change { user.reload.slack_user_id }.from(nil).to(slack_user_id).and change { user.reload.bound_at }.from(nil)
    end
  end

end
