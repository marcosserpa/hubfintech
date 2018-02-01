FactoryGirl.define do
  factory :account do
  end

  factory :main_account, class: Account do
    balance 1.5
    status 'active'
    main true
  end

  factory :filial_account, class: Account do
    balance 1.5
    status 'active'
    main false
  end
end
