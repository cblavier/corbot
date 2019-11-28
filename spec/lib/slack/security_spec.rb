require "spec_helper"

describe Slack::Security do
  subject { described_class.authenticate?(headers, body, settings) }

  let(:headers) {
    {
      "HTTP_X_SLACK_SIGNATURE" => slack_signature,
      "HTTP_X_SLACK_REQUEST_TIMESTAMP" => "123467",
    }
  }
  let(:body) { { "text": "ping" }.to_json }
  let(:settings) {
    OpenStruct.new(
      slack_version_nb: "v0",
      slack_signing_secret: "bar",
    )
  }

  context "with a properly signed request" do
    let(:slack_signature) { "v0=7639016e92709b51e4f32273b86dec6fd073a628cd881e95d065b5c697c0effe" }

    it "should return true" do
      expect(subject).to be true
    end
  end

  context "with a bad signed request" do
    let(:slack_signature) { "whatever" }

    it "should return false" do
      expect(subject).to be false
    end
  end
end
