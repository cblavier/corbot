require "spec_helper.rb"
require "json"

describe "PageBuilder" do

  let(:user) { create_user("12", "42") }

  subject {
    json = Slack::PageBuilder.home_page_view(user)
    JSON.parse(json)
  }

  describe "home_page" do

    it "should generate a page json" do
      json = subject()
      expect(subject["type"]).to eq "home"
      expect(subject["blocks"]).to satisfy{ |blocks| blocks.length == 4 }
    end
  end
end