class StatementsController < ApplicationController
  def index
    @start_date = params[:start_date] || Date.today.beginning_of_month.to_s
    @end_date = params[:end_date] || Date.today.to_s

    # Filter params
    @search_text = params[:search]
    @category_filter = params[:category]

    client = InterClient.new
    @statement_data = client.get_statement(@start_date, @end_date)

    if @statement_data && @statement_data["transacoes"]
      all_transactions = @statement_data["transacoes"]

      # Enhance transactions with a normalized 'display_name' and 'display_category' for easier filtering
      all_transactions.each_with_index do |tx, index|
        Rails.logger.info "TX_DEBUG: #{tx.inspect}" if index == 0
        tx["display_name"] = extract_name(tx)
        tx["display_category"] = tx["tipoTransacao"] || "Outros"
      end

      # Extract unique categories for dropdown
      @categories = all_transactions.map { |tx| tx["display_category"] }.uniq.sort

      # Filter
      if @search_text.present?
        norm_search = @search_text.downcase
        all_transactions.select! do |tx|
          tx["display_name"].to_s.downcase.include?(norm_search) ||
          tx["descricao"].to_s.downcase.include?(norm_search)
        end
      end

      if @category_filter.present?
        all_transactions.select! { |tx| tx["display_category"] == @category_filter }
      end

      @grouped_transactions = group_transactions(all_transactions)
    else
      @grouped_transactions = { inflow: {}, outflow: {} }
      @categories = []
      @error = @statement_data["error"] || @statement_data["title"] if @statement_data
    end
  rescue StandardError => e
    @error = e.message
    @grouped_transactions = { inflow: {}, outflow: {} }
    @categories = []
  end

  private

  def extract_name(tx)
    # Attempt to find the best name field based on common Inter API responses
    tx["nmAgente"] || tx["nomeFavorecido"] || tx["nomePagador"] || tx["titulo"] || "N/A"
  end

  def group_transactions(transactions)
    grouped = { inflow: {}, outflow: {} }

    transactions.each do |tx|
      # Detect Type: "C" or "CREDITO" = Inflow, "D" or "DEBITO" = Outflow
      is_credit = tx["tipoOperacao"] == "C"

      category = tx["display_category"]

      target_group = is_credit ? grouped[:inflow] : grouped[:outflow]

      if target_group[category].nil?
        target_group[category] = { transactions: [], total: 0.0 }
      end

      target_group[category][:transactions] << tx
      target_group[category][:total] += tx["valor"].to_f
    end

    grouped
  end
end
