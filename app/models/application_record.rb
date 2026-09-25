# encoding: UTF-8
# frozen_string_literal: true

# We use the next convention for organizing Ruby on Rails Models.
# https://www.zmwolski.com/Organizing-Ruby-on-Rails-Models
class ApplicationRecord < ActiveRecord::Base
  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # Ransack 4 requires explicit allowlists. Delegating to ransack's full lists
  # keeps the exact ransack 2.x defaults (all columns, ransackers, aliases and
  # associations). Deliberately permissive for the upgrade; tighten per model
  # as a separate hardening task (public endpoints accept a free-form order_by).
  def self.ransackable_attributes(_auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations
  end

  # == Instance Methods =====================================================

  self.abstract_class = true
end
