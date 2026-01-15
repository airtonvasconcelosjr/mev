require 'faraday'
require 'base64'
require 'json'

class InterClient
  BASE_URL = 'https://cdpj.partners.bancointer.com.br'
  TOKEN_URL = '/oauth/v2/token'
  BALANCE_URL = '/banking/v2/saldo'
  EXTRATO_URL = '/banking/v2/extrato'

  def initialize
    @client_id = ENV['INTER_CLIENT_ID']
    @client_secret = ENV['INTER_CLIENT_SECRET']
    @cert_path = ENV['INTER_CERT_PATH']
    @key_path = ENV['INTER_KEY_PATH']

    if [@client_id, @client_secret, @cert_path, @key_path].any?(&:nil?)
      Rails.logger.warn "InterClient: Missing credentials or cert paths in ENV."
    end
  end

  def get_balance(date = nil)
    token = ensure_token
    return { error: 'Failed to authenticate' } unless token

    params = {}
    params[:dataSaldo] = date if date.present?

    response = connection.get(BALANCE_URL, params) do |req|
      req.headers['Authorization'] = "Bearer #{token}"
    end

    handle_response(response)
  end

  def get_statement(start_date, end_date)
    token = ensure_token
    return { error: 'Failed to authenticate' } unless token

    params = {
      dataInicio: start_date,
      dataFim: end_date
    }

    response = connection.get(EXTRATO_URL, params) do |req|
      req.headers['Authorization'] = "Bearer #{token}"
    end

    handle_response(response)
  end

  def get_pix(e2e_id)
    token = ensure_token
    return { error: 'Failed to authenticate' } unless token

    # Pix API endpoint: /pix/v2/pix/{e2eId}
    url = "/pix/v2/pix/#{e2e_id}"

    response = connection.get(url) do |req|
      req.headers['Authorization'] = "Bearer #{token}"
    end

    handle_response(response)
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      # mTLS Configuration
      if File.exist?(@cert_path) && File.exist?(@key_path)
        cert = OpenSSL::X509::Certificate.new(File.read(@cert_path))
        key = OpenSSL::PKey::RSA.new(File.read(@key_path))
        
        conn.ssl[:client_cert] = cert
        conn.ssl[:client_key] = key

      else
        Rails.logger.error "InterClient: Cert/Key file not found at #{@cert_path} or #{@key_path}"
      end
      
      conn.adapter Faraday.default_adapter
    end
  end

  def ensure_token
    # Simple caching mechanism. 
    # In production, use Rails.cache with expiry.
    # Token lasts 60 minutes.
    
    cached_token = Rails.cache.read('inter_access_token')
    return cached_token if cached_token

    fetch_new_token
  end

  def fetch_new_token
    payload = {
      client_id: @client_id,
      client_secret: @client_secret,
      grant_type: 'client_credentials',
      scope: 'extrato.read'
    }

    response = connection.post(TOKEN_URL) do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(payload)
    end

    data = JSON.parse(response.body)
    
    if response.success? && data['access_token']
      # Cache for 50 minutes to be safe (token lasts 60)
      Rails.cache.write('inter_access_token', data['access_token'], expires_in: 50.minutes)
      data['access_token']
    else
      Rails.logger.error "InterClient Auth Failed: #{response.body}"
      nil
    end
  end

  def handle_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    { error: "Invalid JSON response", status: response.status, body: response.body }
  end
end
