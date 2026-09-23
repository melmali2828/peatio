# Rails 7.0: these classes live in lib/peatio (reloadable, Zeitwerk); initializers
# may no longer reference them directly, so register them after each (re)load.
Rails.application.config.to_prepare do
  Peatio::Blockchain.registry[:bitcoin] = Bitcoin::Blockchain
  Peatio::Blockchain.registry[:geth] = Ethereum::Eth::Blockchain
  Peatio::Blockchain.registry[:parity] = Ethereum::Eth::Blockchain
  Peatio::Blockchain.registry[:"geth-bsc"] = Ethereum::Bsc::Blockchain
  Peatio::Blockchain.registry[:"geth-heco"] = Ethereum::Heco::Blockchain
end
