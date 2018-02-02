class Transaction < ActiveRecord::Base
  include Generator

  validates :value, presence: true
  validates :destination, presence: true

  before_save :transfer_destination

  after_commit :update_balances, on: :create

  def transfer_destination
    if destination_account.present? && transfer_to_main? && origin_account.present?
      errors.add(
        :origin,
        'As destination account is a main account, transfer should not have an origin account'
      )
    elsif destination_account.present? && transfer_to_main? && code_generated? || (destination_account.present? && origin_account.present?)
      return true if check_account_status
    end

    false
  end

  def check_account_status
    if transfer_to_main?
      destination_account.active?
    else
      origin_account.present? && origin_account.active? && destination_account.active?
    end
  end

  def set_transation_kind
    self.reversal = 0
  end

  def transfer_to_main?(id = nil)
    if id
      Account.find_by(id: id)
    else
      destination_account.main?
    end
  end

  def code_generated?
    self.code = Generator.transfer_code
  end

  def destination_account
    Account.find_by(id: destination)
  end

  def origin_account
    Account.find_by(id: origin) if origin.present?
  end

  def update_balances
    dest = destination_account
    orig = origin_account

    if transfer_to_main?
      dest.balance = dest.balance + value
      dest.save
    else
      dest.balance = dest.balance + value
      dest.save
      orig.balance = orig.balance - value
      orig.save
    end
  end

  def self.refund(options = {})
    return false if options.empty?

    transaction = rescue_transaction(options)
    destination = Account.find_by(id: transaction.destination)
    origin = Account.find_by(id: transaction.origin)

    if options[:code].present?
      refund_operation = refund_main_account(destination, transaction)

      if refund_operation.save
        destination.balance = destination.balance + refund_operation.value
        destination.save

        return true
      else
        return false
      end
    elsif destination.main?
      return false
    else
      refund_operation = if origin.main?
                           refund_main_account(origin, transaction)
                         else
                           Transaction.new(
                             destination: origin.id,
                             origin: destination.id,
                             code: Generator.transfer_code,
                             reversal: true,
                             value: transaction.value
                           )
                         end

      if refund_operation.save
        destination.balance = destination.balance - transaction.value
        destination.save
        origin.balance = origin.balance + transaction.value
        origin.save

        return true
      else
        return false
      end
    end
  end

  def self.rescue_transaction(options)
    transaction = if options[:code]
                    Transaction.find_by(code: options[:code])
                  elsif options[:id]
                    Transaction.find(options[:id])
                  end

    transaction
  end

  def self.refund_main_account(destination, transaction)
    operation = Transaction.new(
      destination: destination.id,
      code: Generator.transfer_code,
      reversal: true,
      value: - transaction.value
    )

    operation
  end
end
