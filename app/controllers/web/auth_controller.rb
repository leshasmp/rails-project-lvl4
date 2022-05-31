# frozen_string_literal: true

class Web::AuthController < Web::ApplicationController
  helper_method :current_user, :logged_in?

  def callback
    @user = User.find_or_initialize_by(email: user_params[:email])
    @user.nickname = user_params[:nickname]
    @user.name = user_params[:name]
    @user.image_url = user_params[:image_url]
    @user.token = user_params[:token]
    if @user.save
      sign_in @user
      redirect_to root_path, notice: t('.success')
    else
      redirect_to root_path, flash: { error: t('.error') }
    end
  end

  def sign_out
    session.delete(:user_id)
    session.clear
    redirect_to root_path, notice: t('.success')
  end

  def user_params
    {
      nickname: request.env['omniauth.auth'][:info][:nickname].downcase,
      name: request.env['omniauth.auth'][:info][:name],
      email: request.env['omniauth.auth'][:info][:email],
      image_url: request.env['omniauth.auth'][:info][:image],
      token: request.env['omniauth.auth'][:credentials][:token]
    }
  end
end
