# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, :nickname, :token, presence: true
end
