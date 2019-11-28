# frozen_string_literal: true

require 'spec_helper.rb'

describe 'user_service' do
  let(:cookie) { ENV['REFUGE_COOKIE'] }
  let(:csrf) { ENV['REFUGE_CSRF'] }
  let(:city_id) { ENV['CITY_ID'] }
  let(:cassette) { 'refuge/search_users_ok' }

  describe 'update_users_from_refuge' do
    subject do
      VCR.use_cassette(cassette) do
        Corbot::UserService.update_users_from_refuge(city_id, cookie, csrf)
      end
    end

    it 'should create all users' do
      expect { subject }.to change { Corbot::User.count }.from(0).to(67)
      Corbot::User.all.each do |user|
        expect(user.removed).to be false
      end
    end

    it 'should create all users on when ran twice' do
      expect do
        subject
        subject
      end.to change { Corbot::User.count }.from(0).to(67)
    end

    it 'should delete old users' do
      user = create_user(424_242)
      expect { subject }
        .to change  { Corbot::User.count }.from(1).to(68)
        .and change { user.reload.removed }.from(false).to(true)
    end
  end

  describe 'users_without_slack_id' do
    subject { Corbot::UserService.users_without_slack_id }

    context 'with no users' do
      let(:users) { [] }

      it 'should return an empty array' do
        expect(subject).to be_empty
      end
    end

    context 'with some unbound users' do
      let!(:users) do
        3.times.map { |i| create_user(i, i) } + 2.times.map { |i| create_user(i) }
      end

      it 'should return them' do
        expect(subject).to satisfy { |users| users.length == 2 }
      end
    end
  end

  describe 'bind user' do
    let(:user) { create_user("42") }
    let(:slack_user_id) { "37" }
    subject { Corbot::UserService.bind_user(user.refuge_user_id, slack_user_id) }

    it 'should bind slack_user_id and bound_at' do
      expect { subject }
        .to change { user.reload.slack_user_id }.from(nil).to(slack_user_id)
        .and change { user.reload.bound_at }.from(nil)
    end
  end
end
