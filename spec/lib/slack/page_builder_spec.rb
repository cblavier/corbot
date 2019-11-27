require "spec_helper.rb"
require "json"

describe "PageBuilder" do
  subject {
    json = Slack::PageBuilder.home_page_view(user)
    JSON.parse(json)
  }

  describe "home_page" do
    shared_examples "a user home page" do
      it "should generate a home page" do
        expect(subject["type"]).to eq "home"
      end
    
      it "should welcome the user" do
        expect(subject["blocks"]).to satisfy do |blocks| 
          blocks_contain?(blocks, "section", "Bonjour \\*#{user.first_name}\\*")
        end
      end
    end

    context "with an admin user" do
      let(:user) { create_admin("12", "42") }

      it_behaves_like "a user home page"
        
      it "should contain an administration section" do
        expect(subject["blocks"]).to satisfy do |blocks| 
          blocks_contain?(blocks, "section", "Administration")
        end
      end
    end

    context "with a non admin user" do
      let(:user) { create_user("12", "42") }

      it_behaves_like "a user home page"

      it "should not contain an administration section" do
        expect(subject["blocks"]).to_not satisfy do |blocks| 
          blocks_contain?(blocks, "section", "Administration")
        end
      end
    end
  end

  def blocks_contain?(blocks, type, text = nil) 
    blocks.any? do |block| 
      result = (block["type"] == type)
      if text 
        result = result && block["text"] && block["text"]["text"] =~ /.*#{text}.*/i
      end
      result
    end
  end
end