# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize
  include AASM

  belongs_to :user
  has_many :checks, dependent: :destroy

  validates :github_id, presence: true

  aasm do
    state :created, initial: true
    state :fetching
    state :fetched
    state :failed

    event :fetch do
      transitions from: %i[created fetched failed], to: :fetching
    end

    event :to_fetched do
      transitions from: :fetching, to: :fetched
    end

    event :fail do
      transitions from: :fetching, to: :failed
    end
  end

  enumerize :language, in: %i[JavaScript Ruby], default: :JavaScript
end
