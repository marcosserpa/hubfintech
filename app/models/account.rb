class Account < ActiveRecord::Base
  has_many :filials, class_name: 'Account', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Account', required: false
  belongs_to :owner

  validates :owner_id, presence: true
  validates :parent_id, presence: true, unless: :main?

  before_validation :set_status, on: :create
  before_validation :set_main, on: :create

  def set_main
    self.main = self.parent_id.present? ? 0 : 1
  end

  def set_status
    self.status = 'active' if self.status.blank?
  end

  def main?
    main
  end

  def owner
    Owner.find(self.owner_id).try(:name)
  end

  def parent
    Account.find(self.parent_id).try(:id)
  end

  def active?
    self.status == 'active'
  end
end
