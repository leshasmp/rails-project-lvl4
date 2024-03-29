# frozen_string_literal: true

class Repository
  class Check < ApplicationRecord
    include AASM

    belongs_to :repository

    aasm do
      state :created, initial: true
      state :checking
      state :finished
      state :failed

      event :start_check do
        transitions from: :created, to: :checking
      end

      event :finish_check do
        transitions from: :checking, to: :finished
      end

      event :fail do
        transitions from: :checking, to: :failed
      end
    end

    paginates_per 10
  end
end
