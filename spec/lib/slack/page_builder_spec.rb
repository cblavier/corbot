require 'spec_helper'

describe Slack::PageBuilder do
  subject do
    JSON.parse(described_class.home_page_view(user))
  end

  describe 'home_page' do
    shared_examples 'a user home page' do
      it 'should generate a home page' do
        expect(subject['type']).to eq 'home'
      end

      it 'should welcome the user' do
        expect(subject['blocks']).to satisfy do |blocks|
          blocks_contain?(blocks, 'section', text: "Bonjour \\*#{user.first_name}\\*")
        end
      end
    end

    context 'with an admin user' do
      let(:user) { create_user('12', slack_user_id: '42', admin: true) }

      it_behaves_like 'a user home page'

      it 'should contain an administration section' do
        expect(subject['blocks']).to satisfy do |blocks|
          blocks_contain?(blocks, 'section', text: 'Administration')
        end
      end

      context 'with some unbound users' do

        let!(:bound_users)   { (1..5).map{ |i| create_user(i, slack_user_id: i, admin: true)} }
        let!(:unbound_users) { (1..2).map{ |i| create_user(100 + i, admin: true)} }

        it 'should contain a block with the count of users and count of bound users' do
          expect(subject['blocks']).to satisfy do |blocks|
            total_bounds = bound_users.count + 1
            total_users = total_bounds + unbound_users.count
            blocks_contain?(blocks, 'section', text: "Il y a \\*#{total_users} membres\\* du Refuge dont \\*#{total_bounds}\\* avec un compte Slack connu.")
          end
        end
        
        it 'should contain a block with the count of unbound users' do
          expect(subject['blocks']).to satisfy do |blocks|
            blocks_contain?(blocks, 'section', text: "Voici le premier des \\*#{unbound_users.count}\\* restant à associer :")
          end
        end

        it 'should contain a block with a user_select list' do
          expect(subject['blocks']).to satisfy do |blocks|
            blocks_contain?(blocks, 'actions')
          end
        end
      end
    end

    context 'with a non admin user' do
      let(:user) { create_user('12', slack_user_id: '42') }

      it_behaves_like 'a user home page'

      it 'should not contain an administration section' do
        expect(subject['blocks']).to_not satisfy do |blocks|
          blocks_contain?(blocks, 'section', text: 'Administration')
        end
      end
    end
  end

  def blocks_contain?(blocks, type, text: nil)
    blocks.any? do |block|
      result = (block['type'] == type)
      if text
        result = result && block['text'] && block['text']['text'] =~ /.*#{text}.*/i
      end
      result
    end
  end
end
