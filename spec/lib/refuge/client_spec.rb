require "spec_helper"

describe Refuge::Client do
  describe "user profile" do
    let(:cassette) { "refuge/profile_#{user_id}" }

    let(:subject) {
      VCR.use_cassette(cassette) do
        described_class.get_refuge_profile(user_id)
      end
    }

    context "with correct id" do
      let(:user_id) { 2075 }

      it "should return profile" do
        profile = subject()
        expect(profile.id).to eq(user_id)
        expect(profile.first_name).to eq("François")
        expect(profile.last_name).to eq("Ferrandis")
        expect(profile.email).to eq("francois@la-cordee.net")
        expect(profile.description).to eq("💎 + 🎹 + 🍕 + ☭")
        expect(profile.tags).to satisfy { |tags| tags.length == 15 }
      end
    end

    context "with unknown id" do
      let(:user_id) { "unknown" }

      it "should raise not_found error" do
        expect { subject }.to raise_error "redirected (not found?)"
      end
    end
  end

  describe "search_users" do
    let(:cassette) { "refuge/search_users_#{cassette_id}" }
    let(:city_id) { Refuge::Locations.nantes_city_id }

    let(:subject) {
      VCR.use_cassette(cassette) do
        described_class.search_users(city_id)
      end
    }

    context "with correct authentication" do
      let(:cassette_id) { "ok" }

      it "should raise unauthorized error" do
        members = subject()
        expect(members.length).to eq(68)
        expect(members[0].first_name).to eq("Rémi")
        expect(members[66].first_name).to eq("Youcef")
      end
    end
  end
end
