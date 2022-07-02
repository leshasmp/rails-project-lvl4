# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  def index?
    user
  end

  def new?
    user
  end

  def create?
    user
  end

  def show?
    author?
  end

  private

  def author?
    user == record.user
  end
end
