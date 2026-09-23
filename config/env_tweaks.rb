# frozen_string_literal: true

# Replacement for the env-tweaks gem (1.0.1), whose every release requires
# activesupport < 7.0. Semantics are copied verbatim; do not "improve" them:
# ENV.false?('WITHDRAW_ADMIN_APPROVE') decides whether withdrawals are
# processed without admin approval.
#
#   false?(var) -> value is blank (unset, "", whitespace) or exactly one of
#                  "false", "0", "nil", "null" (case-sensitive: "FALSE" is true)
#   true?(var)  -> !false?(var)
#
# Loaded from config/application.rb (not an initializer) because
# config/environments/shared/cache.rb calls ENV.true? before initializers run.
require 'active_support/core_ext/object/blank'

module ENVTweaks
  module Extension
    FALSE_VALUES = %w[false 0 nil null].freeze

    def true?(var)
      !false?(var)
    end

    def false?(var)
      self[var].blank? || FALSE_VALUES.include?(self[var])
    end
  end
end

ENV.extend ENVTweaks::Extension
