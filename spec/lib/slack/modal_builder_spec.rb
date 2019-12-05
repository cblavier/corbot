require 'spec_helper'

describe Slack::ModalBuilder do
  shared_examples 'a modal' do
    it 'should have the good type' do
      expect(subject['type']).to eq 'modal'
    end
  end

  describe 'profile_modal_404' do
    subject do
      JSON.parse(described_class.profile_modal_404)
    end

    it_behaves_like 'a modal'

    it 'should contain error message' do
      expect(subject['blocks']).to satisfy do |blocks|
        blocks_contain?(blocks, 'section', text: "Oups, on dirait que je n'ai pas accès au profil de ce membre")
      end
    end
  end

  describe 'profile_modal' do
    let(:user) { create_user('1') }
    let(:user_profile) do
      {
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'avatar' => 'http://refuge.la-cordee.net/avatar.jpg',
        'tags' => ['cuisine'],
        'description' => 'lorem ipsum',
        'description_1' => 'lorem ipsum',
        'description_2' => 'lorem ipsum',
        'description_3' => 'lorem ipsum',
        'description_4' => 'lorem ipsum',
        'home' => 'Nantes',
        'created_at' => Time.now
      }
    end
    subject do
      JSON.parse(described_class.profile_modal(user, user_profile))
    end

    it_behaves_like 'a modal'

    it 'should have user full name as title' do
      expect(subject['title']['text']).to eq user.full_name
    end

    it 'should contain user description' do
      expect(subject['blocks']).to satisfy do |blocks|
        blocks_contain?(blocks, 'section', text: user_profile['description'])
      end
    end
  end
end
