require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:person) { create(:person) }
  let(:main_account) { create(:main_account, owner: person) }
  let(:filial_account) { build(:filial_account, owner: person, parent_id: main_account.id) }

  let(:filial_account_valid_attributes) do
    {
      owner_id: person.id,
      parent_id: main_account.id
    }
  end
  let(:main_account_valid_attributes) do
    {
      owner_id: person.id
    }
  end

  let(:filial_account_invalid_attributes) do
    {
      owner_id: '',
      parent_id: main_account.id
    }
  end
  let(:main_account_invalid_attributes) do
    {
      owner_id: ''
    }
  end

  let(:valid_session) { {} }

  describe 'parameter whitelisting' do
    let(:params) do
      {
        other: 'stuff',
        account: {
          owner_id: person.id,
          parent_id: main_account.id
        }
      }
    end

    it { is_expected.to permit(:owner_id).for(:create, params: params).on(:account) }
    it { is_expected.to permit(:parent_id).for(:create, params: params).on(:account) }
  end

  describe 'GET #index' do
    context 'when tries to create a main with valid attributes' do
      it 'returns a success response' do
        Account.create! main_account_valid_attributes

        get :index, {}, valid_session
        expect(response).to be_success
      end
    end

    context 'when tries to create an account with valid attributes' do
      it 'returns a success response' do
        Account.create! filial_account_valid_attributes

        get :index, {}, valid_session
        expect(response).to be_success
      end
    end
  end

  describe 'GET #show' do
    let!(:account) { create :person }
    subject(:action) { get :show, params }
    let!(:account) { Account.create! filial_account_valid_attributes }

    it 'returns a success response' do
      get :show, { id: account.to_param }, valid_session
      expect(response).to be_success
    end

    context 'for a valid id' do
      let(:params) { { id: account.id } }

      it 'assigns the requested account to @account' do
        action
        expect(assigns(:account)).to eq account
      end

      context 'given a redirect=no parameter' do
        let(:params) { { id: account.id, redirect: 'no' } }

        it 'renders the :show template' do
          expect(action).to render_template :show
        end

        it 'returns a HTTP 200 (success) status' do
          expect(action).to have_http_status :success
        end
      end
    end
  end

  describe 'GET #new' do
    subject(:action) { get :new }

    before do
      action
    end

    it 'returns a HTTP 200 (success) status' do
      expect(action).to have_http_status :success
    end

    it 'assigns a nean account to @account' do
      action
      expect(assigns(:account)).to be_a Account
    end

    it 'renders the :new template' do
      expect(action).to render_template :new
    end

    it 'returns a success response' do
      get :new, {}, valid_session
      expect(response).to be_success
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      account = Account.create! main_account_valid_attributes

      get :edit, { id: account.to_param }, valid_session
      expect(response).to be_success
    end
  end

  describe 'POST #create' do
    let(:owner_id) { person.id }
    let(:parent_id) { main_account.id }
    let!(:account) { create(:main_account, owner: person) }
    let(:main_account_params) do
      {
        account: {
          owner_id: owner_id,
          parent_id: ''
        }
      }
    end
    let(:filial_account_params) do
      {
        account: {
          owner_id: owner_id,
          parent_id: account.id
        }
      }
    end

    subject(:filial_action) { post :create, filial_account_params }
    subject(:main_action) { post :create, main_account_params }

    context 'with valid attributes' do
      it 'creates a new account' do
        expect { filial_action }.to change(Account, :count).by(1)
      end
      it 'creates a new main' do
        expect { main_action }.to change(Account, :count).by(1)
      end

      it 'sets the success flash message' do
        filial_action
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid attributes' do
      let(:owner_id) { '' }
      let(:parent_id) { '' }

      it 'does not creates a new account' do
        expect { filial_action }.not_to change(Account, :count)
      end
      it 'does not creates a new main' do
        expect { main_action }.not_to change(Account, :count)
      end

      it 're-renders the :new template' do
        expect(filial_action).to render_template :new
        expect(main_action).to render_template :new
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the "new" template)' do
          post :create, { account: filial_account_invalid_attributes }, valid_session
          expect(response).to be_success
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:main_account_params) do
      {
        account: {
          owner_id: person.id,
          parent_id: ''
        }
      }
    end
    let(:filial_account_params) do
      {
        account: {
          owner_id: person.id,
          parent_id: main_account.id
        }
      }
    end

    context 'with valid params' do
      it 'updates the requested account' do
        account = Account.create! filial_account_valid_attributes

        put :update, { id: account.to_param, account: filial_account_params }, valid_session
        account.reload
        skip('Simulate update')
      end

      it 'updates the requested main' do
        account = Account.create! main_account_valid_attributes

        put :update, { id: account.to_param, account: main_account_params }, valid_session
        account.reload
        skip('Simulate update')
      end

      it 'redirects to the account' do
        account = Account.create! filial_account_valid_attributes

        put :update, { id: account.to_param, account: filial_account_valid_attributes }, valid_session
        expect(response).to redirect_to(account)
      end

      it 'redirects to the main' do
        account = Account.create! main_account_valid_attributes

        put :update, { id: account.to_param, account: main_account_valid_attributes }, valid_session
        expect(response).to redirect_to(account)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested account' do
      account = Account.create! filial_account_valid_attributes

      expect do
        delete :destroy, { id: account.to_param }, valid_session
      end.to change(Account, :count).by(-1)
    end

    it 'destroys the requested main' do
      account = Account.create! main_account_valid_attributes

      expect do
        delete :destroy, { id: account.to_param }, valid_session
      end.to change(Account, :count).by(-1)
    end

    it 'redirects to the accounts list' do
      account = Account.create! filial_account_valid_attributes

      delete :destroy, { id: account.to_param }, valid_session
      expect(response).to redirect_to(accounts_url)
    end
  end
end
