# frozen_string_literal: true

module ActiveRecord
  class Base
    def self.inherited(child)
      super
      unless child == ActiveRecord::SchemaMigration
        validates_lengths_from_database
      end
    end
  end
end

database_config = ActiveRecord::Base.configurations
  .configs_for(env_name: Rails.env, spec_name: 'primary')
  .configuration_hash

Rails.configuration.database_support_json = database_config[:support_json]
Rails.configuration.database_adapter = database_config[:adapter]
