# frozen_string_literal: true

class Web::ApplicationController < ApplicationController
  helper_method :current_user, :signed_in?
  include AuthConcern
end
