var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "quote ensure arrive vote dinosaur illegal wood equal disagree teach tray planet";

module.exports = {
  networks: {
    development: {
      // provider: function() {
      //   return new HDWalletProvider(mnemonic, "http://127.0.0.1:8545/",0,50);
      // },
      host: '127.0.0.1',
      port: 8545,
      network_id: '*',
      gas: 6721900
    },
    GanacheUI: {
      host: '127.0.0.1',
      port: 7545,
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