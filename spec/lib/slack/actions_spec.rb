require "spec_helper"

describe Slack::Actions do
  before do
    allow(Thread).to receive(:new).and_yield
    allow(STDOUT).to receive(:puts)
  end

  describe "perform_action" do

    subject {
      VCR.use_cassette("slack/publish_home") do
        described_class.perform_action(params)
      end
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
        expect { subject }.to change { last_bound_user.reload.bound_at }
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

  describe "perform_message_action" do
    subject {
      VCR.use_cassettes([{name: "refuge/profile_#{refuge_user_id}"}, {name: "refuge/profile_unknown"}]) do
        described_class.perform_message_action(action, params)
      end
    }
    
    describe "view_profile" do
      let(:refuge_user_id) { "2075" }
      let(:slack_user_id) { "2" }
      let(:trigger_id) { 'trigger' }

      let(:action) { 'view_profile' }
      let(:params) {{
        trigger_id: trigger_id,
        message: {
          'user' => slack_user_id
        }
      }}

      context "with known user" do
        let!(:user) { create_user(refuge_user_id, slack_user_id: slack_user_id) }

        it "publishes profile modal" do
          expect(Slack::ModalPublisher).to receive(:publish_profile_modal).with(user, any_args, trigger_id)
          subject
        end
      end

      context "with unknown slack user" do
        let!(:user) { create_user(refuge_user_id, slack_user_id: "unknown") }

        it "publishes 404 profile modal" do
          expect(Slack::ModalPublisher).to receive(:publish_profile_modal_404).with(trigger_id)
          subject
        end
      end

      context "with unknown refuge user" do
        let!(:user) { create_user("unknown", slack_user_id: slack_user_id) }

        it "publishes 404 profile modal" do
          expect(Slack::ModalPublisher).to receive(:publish_profile_modal_404).with(trigger_id)
          subject
        end
      end
    end
  end
end
