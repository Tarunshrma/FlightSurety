import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {

    constructor(network, callback) {

        this.config = Config[network];
        //this.web3 = new Web3(new Web3.providers.HttpProvider(this.config.url));
        this.web3 = new Web3(window.ethereum);
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, this.config.appAddress);
        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];

        this.pessangerAddress = null;
    }

    async initialize(callback) {
        if (window.ethereum) {
            self.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            self.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            self.web3Provider = new Web3.providers.HttpProvider(config.url);
        }
        
        this.web3.eth.getAccounts((error, accts) => {
            this.owner = accts[0];
            this.pessangerAddress = accts[9];
            callback();
        });
       
    }

    async getCurrentAccount(){
        var accountsOnEnable = await ethereum.request({method: 'eth_requestAccounts'});
        return accountsOnEnable;
    }

    isOperational(callback) {
       let self = this;
       self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }

    registerAirline(airlineName,airlineAddress,callback) {
        let self = this;
        self.flightSuretyApp.methods
            .registerAirline(airlineName,airlineAddress)
            .send({ from: self.owner, gas: self.config.gas}, callback);
    }

    fundAirline(airlineAddress,callback) {
        let self = this;
        const fee = this.web3.utils.toWei('10', 'ether'); //10 Ether
        self.flightSuretyApp.methods
            .fundAirline(airlineAddress)
            .send({ from: airlineAddress, value: fee}, callback);
    }

    voteAirline(airlineAddress,callback) {
        let self = this;
        self.flightSuretyApp.methods
            .voteAirline(airlineAddress)
            .send({ from: self.owner,  gas: self.config.gas}, callback);
    }

    buyInsurence(flightName,airlineAddress,timestamp,amount,callback) {
        let self = this;
        const insuredAmountInWei = this.web3.utils.toWei(amount, 'ether');
        self.flightSuretyApp.methods
            .buyInsurence(flightName,airlineAddress,timestamp)
            .send({ from: self.owner,  gas: self.config.gas, value : insuredAmountInWei}, callback);
    }

    fetchFlightStatus(flightName,airlineAddress,timestamp, callback) {
        let self = this;
        let payload = {
            airline: airlineAddress,
            flight: flightName,
            timestamp: timestamp
        } 
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }

    checkPessangerBalance(pessangerAddress, callback) {
        let self = this;

        self.web3.eth.getBalance(pessangerAddress, (error,result) => {
            var balance = self.web3.utils.fromWei(result, 'ether');
            callback(error, balance);
        });
    }

    withdrawBalance(pessangerAddress, callback) {
        let self = this;

        self.flightSuretyApp.methods
            .withdrawBalance(pessangerAddress)
            .send({ from: self.owner}, (error, result) => {
                callback(error, result);
            });
    }
}