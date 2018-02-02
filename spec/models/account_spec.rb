require 'rails_helper'

RSpec.describe Account, type: :model do
  describe '#create' do
    let(:person) { create(:person) }
    let(:main_account) { create(:main_account, owner: person) }
    let(:filial_account) { build(:filial_account, owner: person, parent_id: main_account.id) }

    context 'when tries to create a filial account with no owner' do
      it 'should not be a valid account' do
        invalid_account = build(:account, balance: 2.0, status: 'active', main: false)

        expect(invalid_account.save).to be_falsey
      end
    end

    context 'when tries to create a main account with valid infos' do
      it 'should be a valid account' do
        expect(main_account.save).to be_truthy
      end
    end

    context 'when tries to create a filial account with valid infos' do
      it 'should be a valid account' do
        expect(filial_account.save).to be_truthy
      end
    end
  end
end
