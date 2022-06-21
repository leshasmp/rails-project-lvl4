# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def data_check_email
    @user = params[:user]
    @check = params[:check]
    @check_value = JSON.parse(@check.value)
    mail to: @user.email
  end
end
