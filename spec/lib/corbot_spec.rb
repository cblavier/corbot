require "spec_helper"

describe Corbot do
  describe "ping" do
    it "ping should pong" do
      post "/", params = { text: "ping" }
      expect(last_response).to be_ok
      expect(last_response.body).to eq "pong"
    end
  end
end
