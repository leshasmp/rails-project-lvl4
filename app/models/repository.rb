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

    event :start_fetching do
      transitions from: %i[created fetched failed], to: :fetching
    end

    event :complete_fetching do
      transitions from: :fetching, to: :fetched
    end

    event :fail do
      transitions from: :fetching, to: :failed
    end
  end

  enumerize :language, in: %i[javascript ruby]
end
