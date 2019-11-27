require "spec_helper.rb"
require "json"

describe "PagePublisher" do
  let(:user) { create_user("42", "U4SPRR1J8") }

  before do
    allow(STDOUT).to receive(:puts)
  end

  describe "publish_home_page" do

    let(:subject) {
      VCR.use_cassette("slack/publish_home") do
        Slack::PagePublisher.publish_home_page(user)
      end
    }

    it "should return true" do
      expect(subject).to be true
    end
  end
end