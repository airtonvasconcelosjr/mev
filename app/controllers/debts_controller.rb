class DebtsController < ApplicationController
  def index
    @debts = Debt.order(date: :desc, created_at: :desc)
    @new_debt = Debt.new
  end

  def create
    @debt = Debt.new(debt_params)
    if @debt.save
      redirect_to debts_path, notice: "Dívida adicionada com sucesso!"
    else
      @debts = Debt.order(date: :desc, created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @debt = Debt.find(params[:id])
    @debt.destroy
    redirect_to debts_path, notice: "Dívida removida."
  end

  private

  def debt_params
    params.require(:debt).permit(:name, :value, :date)
  end
end
