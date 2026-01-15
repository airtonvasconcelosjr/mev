class HomeController < ApplicationController
  def index
    @start_date = Date.today.beginning_of_month.to_s
    @end_date = Date.today.to_s
    
    client = InterClient.new
    
    # 1. Get Initial Balance (1st of month)
    # The API returns positional balance if date is provided.
    initial_balance_data = client.get_balance(@start_date)
    @initial_balance = initial_balance_data['disponivel'].to_f rescue 0.0
    
    # 2. Get Current Balance
    current_balance_data = client.get_balance # no date = current
    @current_balance = current_balance_data['disponivel'].to_f rescue 0.0
    
    # 3. Get Monthly Transactions for summary
    @statement_data = client.get_statement(@start_date, @end_date)
    
    if @statement_data && @statement_data['transacoes']
      transactions = @statement_data['transacoes']
      @total_inflow = transactions.select { |t| t['tipoOperacao'] == 'C' }.sum { |t| t['valor'].to_f }
      @total_outflow = transactions.select { |t| t['tipoOperacao'] == 'D' }.sum { |t| t['valor'].to_f }
      @transaction_count = transactions.size
    else
      @total_inflow = 0.0
      @total_outflow = 0.0
      @transaction_count = 0
    end
    
    # 4. Debts summary
    @debts = Debt.where(date: Date.today.beginning_of_month..Date.today.end_of_month).or(Debt.where(date: nil))
    @total_debts = @debts.sum(:value)
  end
end
