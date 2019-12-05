require "spec_helper"

describe Slack::ModalPublisher do

  before do
    allow(STDOUT).to receive(:puts)
  end

  describe "publish_profile_modal_404" do
    let(:subject) {
      VCR.use_cassette("slack/publish_profile_modal_404") do
        described_class.publish_profile_modal_404("trigger")
      end
    }

    it "should return true" do
      expect(subject).to be true
    end
  end

  describe "publish_profile_modal" do
    let(:user) { create_user("42", slack_user_id: "U4SPRR1J8") }
    let(:user_profile) do
      {
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'avatar' => "http://refuge.la-cordee.net/avatar.jpg",
        'tags' => ['cuisine'],
        'description' => 'lorem ipsum',
        'description_1' => 'lorem ipsum',
        'description_2' => 'lorem ipsum',
        'description_3' => 'lorem ipsum',
        'description_4' => 'lorem ipsum',
        'home' => 'Nantes',
        'created_at' => Time.now
      }
    end

    let(:subject) {
      VCR.use_cassette("slack/publish_profile_modal") do
        described_class.publish_profile_modal(user, user_profile, "trigger")
      end
    }

    it "should return true" do
      expect(subject).to be true
    end
  end
end