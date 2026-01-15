class BalancesController < ApplicationController
  def index
    @date = params[:date]
    client = InterClient.new
    @balance_data = client.get_balance(@date)
  rescue StandardError => e
    @error = e.message
  end
end
