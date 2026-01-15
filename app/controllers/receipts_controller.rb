class ReceiptsController < ApplicationController
  def show
    @e2e_id = params[:id]
    
    client = InterClient.new
    # Fetch details from Pix API
    @pix_data = client.get_pix(@e2e_id)
    
    if @pix_data['error'] || @pix_data['title']
       @error = "Não foi possível carregar o comprovante: #{@pix_data['title'] || @pix_data['error']}"
    end
  rescue StandardError => e
    @error = e.message
  end
end
