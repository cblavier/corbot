require "spec_helper"

describe Slack::Actions do
  before do
    allow(Thread).to receive(:new).and_yield
  end

  subject {
    described_class.perform(params)
  }

  describe "bind_user" do
    let!(:user) { create_user("12") }
    let(:slack_id) { "42" }
    let(:params) {
      {
        "action_id" => "bind_user_#{user.refuge_user_id}",
        "selected_user" => slack_id,
      }
    }

    it "binds user" do
      expect { subject }.to change { user.reload.slack_user_id }.from(nil).to(slack_id)
    end
  end

  describe "cancel_last_bind" do
    let!(:first_bound_user) { create_user("12", slack_user_id: "32", bound_at: 2.hours.ago) }
    let!(:last_bound_user) { create_user("12", slack_user_id: "42", bound_at: 1.hour.ago) }
    let(:params) {
      {
        "action_id" => "admin_overflow",
        "selected_option" => { "value" => "cancel_last_bind" },
      }
    }

    it "unset last bound user slack_user_id" do
      expect { subject }.to change { last_bound_user.reload.slack_user_id }
          .from(last_bound_user.slack_user_id)
          .to(nil)
    end

    it "unset last bound user bound_at" do
      initial_value = last_bound_user.bound_at
      expect { subject }.to change { last_bound_user.reload.bound_at }
          .from(initial_value)
          .to(nil)
    end

    it "does not modify first bound user" do
      expect { subject }.not_to change { first_bound_user.reload }
    end
  end

  describe "ignore_bind" do
    let!(:user) { create_user("12") }
    let(:params) {
      {
        "action_id" => "admin_overflow",
        "selected_option" => { "value" => "ignore_bind_#{user.refuge_user_id}" },
      }
    }

    it "ignores user" do
      expect { subject }.to change { user.reload.ignored }.from(false).to(true)
    end
  end
end
