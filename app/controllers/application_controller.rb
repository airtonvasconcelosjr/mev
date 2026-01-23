class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :user_name
  before_action :authenticate_user!

  private

  def current_user
    @current_user ||= session[:user_email] if session[:user_email]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to login_path unless logged_in?
  end

  def allowed_users
    {
      ENV["USER1_EMAIL"] => ENV["USER1_PASSWORD"],
      ENV["USER2_EMAIL"] => ENV["USER2_PASSWORD"],
      ENV["USER3_EMAIL"] => ENV["USER3_PASSWORD"]
    }.compact
  end

  def user_name
    if current_user == ENV["USER1_EMAIL"]
      "Airtão"
    elsif current_user == ENV["USER2_EMAIL"]
      "Xuxa"
    elsif current_user == ENV["USER3_EMAIL"]
      "Dedei"
    else
      "Usuário Desconhecido"
    end
  end
end
