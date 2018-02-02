class TransactionsController < ApplicationController
  before_action :check_refund_params, only: :refund

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      render json: @errors, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  def refund
    if Transaction.refund(params[:transaction])
      render json: @errors, status: :created
    else
      render json: 'Parameter error', status: :unprocessable_entity
    end
  end

  private

  def check_refund_params
    if params[:transaction][:code].blank? && params[:transaction][:id].blank?
      render json: { message: 'Not Found' }, status: 404
    end
  end

  def transaction_params
    params.require(:transaction).permit(:origin, :destination, :value)
  end
end
