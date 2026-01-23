class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def new
  end

  def create
    email = params[:email]
    password = params[:password]

    if allowed_users[email] && allowed_users[email] == password
      session[:user_email] = email
      redirect_to root_path, notice: "Logado com sucesso!"
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_email] = nil
    redirect_to login_path, notice: "Logout realizado!"
  end
end
