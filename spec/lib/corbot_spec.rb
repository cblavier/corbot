require "spec_helper.rb"

describe "corbot Application" do
  it "ping should pong" do
    post "/", params = { text: "ping" }
    expect(last_response).to be_ok
    expect(last_response.body).to eq "pong"
  end
end
""
