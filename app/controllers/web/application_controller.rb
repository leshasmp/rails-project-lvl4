# frozen_string_literal: true

class Web::ApplicationController < ApplicationController
  helper_method :current_user, :signed_in?
  include AuthConcern

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    redirect_to root_path, flash: { error: t('authorization.error') }
  end
end
