import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import FlightSuretyData from '../../build/contracts/FlightSuretyData.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';
import "babel-polyfill";

let config = Config['localhost'];
let web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
web3.eth.defaultAccount = web3.eth.accounts[0];
const accounts = web3.eth.getAccounts();
let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
let flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, config.dataAddress);
let oracles = [];
const NUMBER_OF_ORACLE_ACCOUNTS  = 20;


async function registerOracles() {
  let fee = await flightSuretyApp.methods.REGISTRATION_FEE().call();
  let accts = await accounts;
  let numberOfOracles = NUMBER_OF_ORACLE_ACCOUNTS;
  if (accts.length < config.numOracles) {
    numberOfOracles = accts.length;
  }

  for (var i = 0; i < numberOfOracles; i++) {
    console.log("Registring Oracles: " + i);

    oracles.push(accts[i]);
    await flightSuretyApp.methods.registerOracle().send({
      from: accts[i],
      value: fee,
      gas: config.gas
    });
  }
}

async function submitOracleResponse(requestedIndex, airline, flight, timestamp) {
  for (var i = 0; i < oracles.length; i++) {
    var statusCode = 20; //Make the flight late everytime to simulate the auto credit to insured acount
    var indexes = await flightSuretyApp.methods.getMyIndexes().call({from: oracles[i]});
    for (var j = 0; j < indexes.length; j++) {
      try {

        if(requestedIndex == j){
          console.log("Submitting Oracle Response For Flight: " + flight + " At Index: " + indexes[j]);

          await flightSuretyApp.methods.submitOracleResponse(
            indexes[j], airline, flight, timestamp, statusCode
          ).send({from: oracles[i], gas: config.gas});

        }
      } catch(e) {
        console.log(e);
      }
    }
  }
}


//Simulate that everytime client fetch the status of flight it is delayed.. 
//ideally this should not be the case :-)
async function listenEvents() {

  flightSuretyApp.events.OracleRequest({}, async (error, event)  => {
    logEvent(event, "ORACLE REQUEST AT INDEX : " + event.returnValues[0]);
    if (!error) {
      await submitOracleResponse(
        event.returnValues[0], //requested index
        event.returnValues[1], // airline
        event.returnValues[2], // flight
        event.returnValues[3] // timestamp
      );
    }
  });

  flightSuretyData.events.AmountCreditedToPessangerForDelayedFlight({}, async (error, event)  => {
    logEvent(event, "AmountCreditedToPessangerForDelayedFlight");
  });

  flightSuretyData.events.withdrawCreditedAmountEvent({}, async (error, event)  => {
    logEvent(event, "withdrawCreditedAmountEvent");
  });

}

function logEvent(event, title) {
    console.log('----- EVENT -----');
    console.log(title);
    console.log(event.returnValues);
    console.log('-----------------');
}

registerOracles();
listenEvents();

const app = express();
app.get('/api', (req, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    })
})

export default app;


