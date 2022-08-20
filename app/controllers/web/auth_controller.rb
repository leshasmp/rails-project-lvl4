# frozen_string_literal: true

class Web::AuthController < Web::ApplicationController
  def callback
    @user = User.find_or_initialize_by(email: request.env['omniauth.auth'][:info][:email])
    @user.nickname = request.env['omniauth.auth'][:info][:nickname]
    @user.name = request.env['omniauth.auth'][:info][:name]
    @user.image_url = request.env['omniauth.auth'][:info][:image]
    @user.token = request.env['omniauth.auth'][:credentials][:token]
    if @user.save
      sign_in @user
      redirect_to root_path, notice: t('.success')
    else
      redirect_to root_path, flash: { error: t('.error') }
    end
  end
end
