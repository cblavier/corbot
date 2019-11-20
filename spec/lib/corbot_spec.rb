require 'spec_helper.rb'

describe "corbot Application" do

  it "should ping pong" do
    get '/ping'
    expect(last_response).to be_ok
    expect(last_response.body).to eq "pong"
  end

end