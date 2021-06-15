import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {

    constructor(network, callback) {

        this.config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(this.config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, this.config.appAddress);
        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];
    }

    async initialize(callback) {
        // this.web3.eth.getAccounts((error, accts) => {
           
        //     this.owner = accts[0];

        //     let counter = 1;
            
        //     while(this.airlines.length < 5) {
        //         this.airlines.push(accts[counter++]);
        //     }

        //     while(this.passengers.length < 5) {
        //         this.passengers.push(accts[counter++]);
        //     }

        //     callback();
        // });

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
            callback();
        });
       
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
            .send({ from: self.owner, gas: this.config.gas}, callback);
    }

    fundAirline(airlineAddress,callback) {
        let self = this;
        const fee = this.web3.utils.toWei('10', 'ether'); //10 Ether
        self.flightSuretyApp.methods
            .fundAirline(airlineAddress)
            .send({ from: airlineAddress, value: fee}, callback);
    }

    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }
}