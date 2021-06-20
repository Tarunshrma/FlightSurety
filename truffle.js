var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "churn oak eternal cinnamon crane bulk dragon various cry common trap match";

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