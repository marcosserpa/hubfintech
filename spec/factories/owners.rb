FactoryGirl.define do
  factory :owner do
  end

  factory :person, class: Owner do
    name 'Owner Name'
    company_name ''
    owner_national_number CPF.generate.to_s
    birthday '2018-01-31'
    company false
  end

  factory :company, class: Owner do
    name 'Name'
    company_name 'Company Name'
    owner_national_number CNPJ.generate.to_s
    birthday ''
    company true
  end
end
