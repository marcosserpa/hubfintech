require 'rails_helper'

RSpec.describe Owner, type: :model do
  describe '#create' do
    let(:company) { build(:company) }
    let(:person) { build(:person) }

    context 'when tries to create an owner with no name' do
      it 'should not be a valid owner' do
        owner = build(:owner, name: '')

        expect(owner.save).to be_falsey
      end
    end

    context 'when tries to create a person with no birthday' do
      it 'should not be a valid person' do
        person = build(:owner, name: 'Name', birthday: nil, owner_national_number: CPF.generate.to_s)

        expect(person.save).to be_falsey
      end
    end

    context 'when tries to create a person with no CPF' do
      it 'should not be a valid person' do
        person = build(:owner, name: 'Name', birthday: Time.zone.today, owner_national_number: '')

        expect(person.save).to be_falsey
      end
    end

    context 'when tries to create a company with no CNPJ' do
      it 'should not be a valid company' do
        company = build(:owner, name: 'Name', company_name: 'Company Name', owner_national_number: '', company: true)

        expect(company.save).to be_falsey
      end
    end

    context 'when tries to create a company with no company name' do
      it 'should not be a valid company' do
        company = build(:owner, name: 'Name', company_name: '', owner_national_number: CNPJ.generate.to_s, company: true)

        expect(company.save).to be_falsey
      end
    end

    context 'when tries to create a person with valid infos' do
      it 'should not be a valid company' do
        person = build(:person)

        expect(person.save).to be_truthy
      end
    end

    context 'when tries to create a company with valid infos' do
      it 'should not be a valid company' do
        company = build(:company)

        expect(company.save).to be_truthy
      end
    end
  end
end
