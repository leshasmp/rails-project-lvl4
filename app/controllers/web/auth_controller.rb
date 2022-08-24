# frozen_string_literal: true

class Web::AuthController < Web::ApplicationController
  def callback
    data_user = request.env['omniauth.auth']
    @user = User.find_or_initialize_by(email: data_user[:info][:email])
    @user.nickname = data_user[:info][:nickname]
    @user.name = data_user[:info][:name]
    @user.image_url = data_user[:info][:image]
    @user.token = data_user[:credentials][:token]
    if @user.save
      sign_in @user
      redirect_to root_path, notice: t('.success')
    else
      redirect_to root_path, flash: { error: t('.error') }
    end
  end

  def log_out
    sign_out
  end
end
