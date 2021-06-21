var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "network they flat loop october patch urge enrich okay core suggest dune";

module.exports = {
  networks: {
    development: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "http://127.0.0.1:7545/", 0, 50);
      },
      network_id: '*',
      gas: 6721900
    }
  },
  compilers: {
    solc: {
      version: "^0.4.24"
    }
  }
};