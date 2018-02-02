require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:initial_value) { 45.0 }
  let(:initial_value_2) { 21.0 }
  let(:initial_value_3) { 118.0 }
  let(:person) { create(:person) }
  let(:main_account) { create(:main_account, owner: person, balance: initial_value) }
  let(:canceled_main_account) { create(:main_account, owner: person, balance: initial_value, status: 'canceled') }
  let(:blocked_main_account) { create(:main_account, owner: person, balance: initial_value, status: 'blocked') }
  let(:filial_account_1) { create(:filial_account, owner: person, parent_id: main_account.id, balance: initial_value_2) }
  let(:filial_account_2) { create(:filial_account, owner: person, parent_id: main_account.id, balance: initial_value_3) }
  let(:canceled_filial_account) { create(:filial_account, owner: person, balance: initial_value, status: 'canceled') }
  let(:blocked_filial_account) { create(:filial_account, owner: person, balance: initial_value, status: 'blocked') }

  describe '#create' do
    context 'when destination is a main account' do
      let(:transfer1) { build(:transaction, destination: canceled_main_account.id, value: 10.0) }
      let(:transfer2) { build(:transaction, destination: blocked_main_account.id, value: 10.0) }
      let(:transfer) { build(:transaction, destination: main_account.id, value: 10.0) }

      it 'should not have an origin' do
        transfer.origin = filial_account_1.id

        expect(transfer.save).to be_falsey
      end

      it 'should be active' do
        expect(transfer1.save).to be_falsey
        expect(transfer2.save).to be_falsey
      end

      it 'should create a code' do
        expect(transfer.save).to be_truthy
        expect(transfer.code).to_not be_empty
      end

      it 'should change the balance' do
        transfer.save

        expect(main_account.reload.balance).to be(initial_value + transfer.value)
      end
    end

    context 'when destination is a filial account' do
      let(:transfer1) { build(:transaction, destination: canceled_filial_account.id, value: 4) }
      let(:transfer2) { build(:transaction, destination: blocked_filial_account.id, value: 4) }
      let(:transfer) { build(:transaction, destination: filial_account_1.id, value: 4) }

      it 'should not have create a code' do
        transfer.code = transfer_code

        expect(transfer.save).to be_falsey
      end

      it 'should have an origin' do
        expect(transfer.save).to be_falsey
      end

      it 'should be active' do
        transfer.origin = main_account.id

        expect(transfer1.save).to be_falsey
        expect(transfer2.save).to be_falsey
      end

      it 'should be done with right infos' do
        initial_main_balance = main_account.balance
        initial_filial_balance = filial_account_1.balance
        transfer.origin = main_account.id

        expect(transfer.save).to be_truthy
        expect(main_account.reload.balance).to be(initial_main_balance - transfer.value)
        expect(filial_account_1.reload.balance).to be(initial_filial_balance + transfer.value)
      end
    end
  end

  describe '#refund' do
    context 'when transaction was to a main account' do
      let(:transfer) { create(:transaction, destination: main_account.id, code: transfer_code, reversal: false, value: 2.0) }

      it 'should not do the transfer without the code' do
        expect(Transaction.refund('')).to be_falsey
      end

      it 'should do the transfer with the right infos' do
        main_balance = main_account.balance

        expect(Transaction.refund(code: transfer.code)).to be_truthy
        expect(main_account.reload.balance).to be(initial_value)
      end
    end

    context 'when transaction was to a filial account' do
      let!(:transfer) do
        create(
          :transaction,
          origin: filial_account_1.id,
          destination: filial_account_2.id,
          reversal: false,
          value: 3.0
        )
      end

      it 'should not do the transfer without the transfer id' do
        expect(Transaction.refund('')).to be_falsey
      end

      it 'should do the transfer with the right infos' do
        expect(Transaction.refund(id: transfer.id)).to be_truthy
        expect(filial_account_1.reload.balance).to be(initial_value_2)
        expect(filial_account_2.reload.balance).to be(initial_value_3)
      end
    end
  end
end

