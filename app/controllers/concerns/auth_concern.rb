# frozen_string_literal: true

module AuthConcern
  extend ActiveSupport::Concern

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def signed_in?
    session[:user_id].present? && current_user.present?
  end

  def sign_out
    session.delete(:user_id)
    session.clear
    redirect_to root_path, notice: t('.success')
  end
end
