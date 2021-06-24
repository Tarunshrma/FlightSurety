
var FlightSuretyApp = artifacts.require("FlightSuretyApp");
var FlightSuretyData = artifacts.require("FlightSuretyData");
var BigNumber = require('bignumber.js');

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0x17418c93c5ee7fbbb04eb57f1e5a92b493aadcd0",
        "0x0a80df5e588e95434d5d89a6f15f80599ac6a062",
        "0xc01b46cb763aeb3c3dc39357dfaecaf676d402fe",
        "0x7059e8fb80cb8831f17f42a9a3a6f5bb46305a6d",
        "0xb4d62272884bc27601385050911da63e2ae18e47",
        "0xa89d33d9a3d5e9a04b6dba87ffcd51766f31ff5a",
        "0x39c328ae96ac7d3c8536e6b20c5b5ab20119d519",
        "0x324792267a2214b6dc7141482db15f65c25bcde9",
        "0x6089ead5a9e754925c377666576854520da331dc",
        "0x293b85d27bc3ca387a4f0ca8c413a041c44c42d8"
    ];


    let owner = accounts[0];
    let firstAirline = accounts[1];

    let flightSuretyData = await FlightSuretyData.new();
    let flightSuretyApp = await FlightSuretyApp.new(flightSuretyData.address);

    
    return {
        owner: owner,
        firstAirline: firstAirline,
        weiMultiple: (new BigNumber(10)).pow(18),
        testAddresses: testAddresses,
        flightSuretyData: flightSuretyData,
        flightSuretyApp: flightSuretyApp
    }
}

module.exports = {
    Config: Config
};