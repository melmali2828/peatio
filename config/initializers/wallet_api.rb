# Rails 7.0: these classes live in lib/peatio (reloadable, Zeitwerk); initializers
# may no longer reference them directly, so register them after each (re)load.
Rails.application.config.to_prepare do
  Peatio::Wallet.registry[:bitcoind] = Bitcoin::Wallet
  Peatio::Wallet.registry[:geth] = Ethereum::Eth::Wallet
  Peatio::Wallet.registry[:parity] = Ethereum::Eth::Wallet
  Peatio::Wallet.registry[:gnosis] = Gnosis::Wallet
  Peatio::Wallet.registry[:"ow-hdwallet-eth"] = OWHDWallet::WalletETH
  Peatio::Wallet.registry[:"ow-hdwallet-bsc"] = OWHDWallet::WalletBSC
  Peatio::Wallet.registry[:"ow-hdwallet-heco"] = OWHDWallet::WalletHECO
  Peatio::Wallet.registry[:opendax_cloud] = OpendaxCloud::Wallet
end
