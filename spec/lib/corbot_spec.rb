require "spec_helper"

describe Corbot do
  describe "/ping" do
    subject do
      get("/ping")
      last_response
    end

    it "should pong" do
      expect(subject).to be_ok
      expect(subject.body).to eq "pong"
    end
  end

  describe "/interactive" do
    subject do
      post("/interactive", params)
      last_response
    end

    context "when payload is missing" do
      let(:params) { {} }

      it "should return 400" do
        expect(subject.status).to eq 400
      end
    end

    context "when actions is missing in payload" do
      let(:params) { { payload: {}.to_json } }

      it "should return 400" do
        expect(subject.status).to eq 400
      end
    end

    context "when actions is valid" do
      let(:params) {
        { payload: { actions: [
          { action_id: "bind_user_1" },
        ] }.to_json }
      }

      it "should return 200" do
        expect(subject).to be_ok
      end
    end
  end
end
