# Rails 7.0: UUID lives in lib/peatio (autoloaded, reloadable) and may not be
# referenced from an initializer directly. Register lazily: the block resolves
# UUID::Type only when a model first looks up :uuid. Wrapping this in
# to_prepare instead is not enough - matching_engine's to_prepare block loads
# Order (which uses :uuid) before this file's block would run.
# Same call shape as register(:uuid, UUID::Type) uses internally.
ActiveRecord::Type.register(:uuid) { |_, *args| UUID::Type.new(*args) }
