class Owner < ActiveRecord::Base
  has_many :accounts

  validates :owner_national_number, presence: true
  validates :name, presence: true
  validate :check_birthday
  validate :check_company_name
  validate :valid_national_number?

  def check_birthday
    errors.add(:birthday, 'Birthday cannot be blank') unless company? || birthday.present?
  end

  def check_company_name
    errors.add(:company_name, 'Company Name cannot be blank') if company? && company_name.blank?
  end

  def valid_national_number?
    if company?
      errors.add(:owner_national_number, 'CNPJ number is not valid') unless CNPJ.valid? owner_national_number
    else
      errors.add(:owner_national_number, 'CPF number is not valid') unless CPF.valid? owner_national_number
    end
  end

  def company?
    company.present?
  end
end
