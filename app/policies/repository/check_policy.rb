# frozen_string_literal: true

class Repository::CheckPolicy < ApplicationPolicy
  def create?
    author?
  end

  def show?
    author?
  end

  private

  def author?
    user == record.repository.user
  end
end
