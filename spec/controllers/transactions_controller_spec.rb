require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:person) { create(:person) }
  let(:main_account) { create(:main_account, owner: person) }
  let(:filial_account) { create(:filial_account, owner: person, parent_id: main_account.id) }

  let(:valid_session) { {} }

  describe 'parameter whitelisting' do
    let(:params) do
      {
        other: 'stuff',
        transaction: {
          destination: filial_account.id,
          origin: main_account.id,
          value: 10.0
        }
      }
    end
  end

  describe '#transfer' do
    let(:main_transfer_account_params) do
      {
        transaction: {
          destination: main_account.id,
          value: 10.0
        }
      }
    end
    let(:filial_transfer_account_params) do
      {
        transaction: {
          destination: filial_account.id,
          origin: main_account.id,
          value: 10.0
        }
      }
    end

    subject(:filial_action) { post :create, filial_transfer_account_params }
    subject(:main_action) { post :create, main_transfer_account_params }

    context 'with valid attributes' do
      it 'creates a new transaction' do
        expect { filial_action }.to change(Transaction, :count).by(1)
      end
      it 'creates a new main' do
        expect { main_action }.to change(Transaction, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      let(:main_transfer_account_params) do
        {
          transaction: {
            value: 10.0
          }
        }
      end
      let(:filial_transfer_account_params) do
        {
          transaction: {
            origin: main_account.id,
            value: 10.0
          }
        }
      end

      subject(:filial_action) { post :create, filial_transfer_account_params }
      subject(:main_action) { post :create, main_transfer_account_params }

      it 'does not creates a new transaction' do
        expect { filial_action }.not_to change(Transaction, :count)
      end
      it 'does not creates a new main' do
        expect { main_action }.not_to change(Transaction, :count)
      end
    end
  end

  describe '.refund' do
    let!(:transfer) { create(:transaction, destination: main_account.id, code: transfer_code, reversal: false, value: 2.0) }
    let!(:filial_transfer) do
      create(:transaction, origin: main_account.id, destination: filial_account.id, reversal: false, value: 2.0)
    end
    let(:refund_of_main) do
      {
        transaction: {
          code: transfer.code
        }
      }
    end
    let(:refund_of_filial) do
      {
        transaction: {
          id: filial_transfer.id
        }
      }
    end
    let(:invalid_refund_of_main) do
      {
        transaction: {
          code: ''
        }
      }
    end
    let(:invalid_refund_of_filial) do
      {
        transaction: {
          id: ''
        }
      }
    end

    subject(:filial_action) { post :refund, refund_of_filial }
    subject(:main_action) { post :refund, refund_of_main }
    subject(:invalid_filial_action) { post :refund, invalid_refund_of_filial }
    subject(:invalid_main_action) { post :refund, invalid_refund_of_main }

    context 'with valid attributes to a main account' do
      it 'refunds a transaction' do
        expect { main_action }.to change(Transaction, :count).by(1)
        expect(Transaction.last.reversal).to be_truthy
      end
    end

    context 'with invalid attributes to a main account' do
      it 'refunds a transaction' do
        expect { invalid_main_action }.not_to(change { Transaction.count })
      end
      it 'creates a new main' do
        expect(Transaction.last.reversal).to be_falsey
      end
    end

    context 'with valid attributes to a filial account' do
      it 'refunds a transaction' do
        expect { filial_action }.to change(Transaction, :count).by(1)
        expect(Transaction.last.reversal).to be_truthy
      end
    end

    context 'with invalid attributes to a main account' do
      it 'refunds a transaction' do
        expect { invalid_filial_action }.not_to(change { Transaction.count })
      end
      it 'creates a new main' do
        expect(Transaction.last.reversal).to be_falsey
      end
    end
  end
end
