require 'rails_helper'

RSpec.describe OwnersController, type: :controller do
  let(:name) { 'Name' }
  let(:company_name) { 'Company Name' }
  let(:cpf) { CPF.generate.to_s }
  let(:cnpj) { CNPJ.generate.to_s }
  let(:birthday) { Time.zone.today }
  let(:company) { true }
  let(:person_valid_attributes) do
    {
      name: name,
      owner_national_number: cpf,
      birthday: birthday,
      company: false
    }
  end
  let(:company_valid_attributes) do
    {
      name: name,
      company_name: company_name,
      owner_national_number: cnpj,
      company: company
    }
  end
  let(:person_invalid_attributes) do
    {
      owner_national_number: cpf,
      birthday: birthday,
      company: false
    }
  end
  let(:company_invalid_attributes) do
    {
      name: name,
      owner_national_number: cnpj,
      company: company
    }
  end

  let(:valid_session) { {} }

  describe 'parameter whitelisting' do
    let(:params) do
      {
        other: 'stuff',
        owner: {
          name: 'Name',
          company_name: 'Company Name',
          birthday: Time.zone.today,
          company: true,
          owner_national_number: CPF.generate.to_s
        }
      }
    end

    it { is_expected.to permit(:name).for(:create, params: params).on(:owner) }
    it { is_expected.to permit(:company_name).for(:create, params: params).on(:owner) }
    it { is_expected.to permit(:birthday).for(:create, params: params).on(:owner) }
    it { is_expected.to permit(:company).for(:create, params: params).on(:owner) }
    it { is_expected.to permit(:owner_national_number).for(:create, params: params).on(:owner) }
  end

  describe 'GET #index' do
    context 'when tries to create a company with valid attributes' do
      it 'returns a success response' do
        Owner.create! company_valid_attributes

        get :index, {}, valid_session
        expect(response).to be_success
      end
    end

    context 'when tries to create a person with valid attributes' do
      it 'returns a success response' do
        Owner.create! person_valid_attributes

        get :index, {}, valid_session
        expect(response).to be_success
      end
    end
  end

  describe 'GET #show' do
    let!(:owner) { create :person }
    subject(:action) { get :show, params }

    it 'returns a success response' do
      owner = Owner.create! person_valid_attributes

      get :show, { id: owner.to_param }, valid_session
      expect(response).to be_success
    end

    context 'for a valid id' do
      let(:params) { { id: owner.id } }

      it 'assigns the requested owner to @owner' do
        action
        expect(assigns(:owner)).to eq owner
      end

      context 'given a redirect=no parameter' do
        let(:params) { { id: owner.id, redirect: 'no' } }

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

    it 'assigns a new person to @owner' do
      action
      expect(assigns(:owner)).to be_a Owner
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
      owner = Owner.create! company_valid_attributes

      get :edit, { id: owner.to_param }, valid_session
      expect(response).to be_success
    end
  end

  describe 'POST #create' do
    # let(:url) { 'http://valid.url.com/some/path' }
    # let(:advertiser_name) { 'Advertiser Test' }
    # let(:starts_at) { Time.zone.now }
    # let(:description) do
    #   'blablabla blablabla description blabla blablabla description blabla blablabla description blabla'
    # end

    let(:person_params) do
      {
        owner: {
          name: name,
          owner_national_number: cpf,
          birthday: birthday,
          company: false
        }
      }
    end
    let(:company_params) do
      {
        owner: {
          name: name,
          company_name: company_name,
          owner_national_number: cnpj,
          company: company
        }
      }
    end

    subject(:person_action) { post :create, person_params }
    subject(:company_action) { post :create, company_params }

    context 'with valid attributes' do
      it 'creates a new person' do
        expect { person_action }.to change(Owner, :count).by(1)
      end
      it 'creates a new company' do
        expect { company_action }.to change(Owner, :count).by(1)
      end

      it 'sets the success flash message' do
        person_action
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid attributes' do
      let(:company_name) { '' }
      let(:birthday) { '' }

      it 'does not creates a new person' do
        expect { person_action }.not_to change(Owner, :count)
      end
      it 'does not creates a new company' do
        expect { company_action }.not_to change(Owner, :count)
      end

      it 're-renders the :new template' do
        expect(person_action).to render_template :new
        expect(company_action).to render_template :new
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the "new" template)' do
          post :create, { owner: person_invalid_attributes }, valid_session
          expect(response).to be_success
        end
      end
    end
  end

  describe 'PUT #update' do
    # let(:url) { 'http://valid.url.com/some/path' }
    # let(:advertiser_name) { 'Advertiser Test' }
    # let(:starts_at) { Time.zone.now }
    # let(:description) do
    #   'blablabla blablabla description blabla blablabla description blabla blablabla description blabla'
    # end
    # let(:params) do
    #   {
    #     owner: {
    #       advertiser_name: advertiser_name,
    #       url: url,
    #       starts_at: starts_at,
    #       description: description
    #     }
    #   }
    # end
    # let(:invalid_params) do
    #   {
    #     advertiser_name: advertiser_name,
    #     url: url,
    #     description: description
    #   }
    # end
    # subject(:action) { post :create, params }
    let(:person_params) do
      {
        owner: {
          name: name,
          owner_national_number: cpf,
          birthday: birthday,
          company: false
        }
      }
    end
    let(:company_params) do
      {
        owner: {
          name: name,
          company_name: company_name,
          owner_national_number: cnpj,
          company: company
        }
      }
    end

    context 'with valid params' do
      it 'updates the requested person' do
        owner = Owner.create! person_valid_attributes

        put :update, { id: owner.to_param, owner: person_params }, valid_session
        owner.reload
        skip('Add assertions for updated state')
      end

      it 'updates the requested company' do
        owner = Owner.create! company_valid_attributes

        put :update, { id: owner.to_param, owner: company_params }, valid_session
        owner.reload
        skip('Add assertions for updated state')
      end

      it 'redirects to the owner' do
        owner = Owner.create! person_valid_attributes

        put :update, { id: owner.to_param, owner: person_valid_attributes }, valid_session
        expect(response).to redirect_to(owner)
      end

      it 'redirects to the company' do
        owner = Owner.create! company_valid_attributes

        put :update, { id: owner.to_param, owner: company_valid_attributes }, valid_session
        expect(response).to redirect_to(owner)
      end
    end

    # context 'with invalid params' do
    #   let(:url) { 'invalid.url' }

    #   it 'does not create a new owner' do
    #     expect { action }.not_to change(Owner, :count)
    #   end

    #   it 're-renders the :new template' do
    #     expect(action).to render_template :new
    #   end
    # end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested person' do
      owner = Owner.create! person_valid_attributes

      expect do
        delete :destroy, { id: owner.to_param }, valid_session
      end.to change(Owner, :count).by(-1)
    end

    it 'destroys the requested company' do
      owner = Owner.create! company_valid_attributes

      expect do
        delete :destroy, { id: owner.to_param }, valid_session
      end.to change(Owner, :count).by(-1)
    end

    it 'redirects to the owners list' do
      owner = Owner.create! person_valid_attributes

      delete :destroy, { id: owner.to_param }, valid_session
      expect(response).to redirect_to(owners_url)
    end
  end
end
