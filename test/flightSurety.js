
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.setAuthorizeContract(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {

    }
    let result = await config.flightSuretyApp.isAirlineRegistered(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });

  it('Airline can not be funded with less then 10 ether', async () => {
    
    // ARRANGE
    const fee = web3.utils.toWei('9',"ether");

    // ACT
    try {
        await config.flightSuretyApp.fundAirline(config.owner,{ from: config.owner, value: fee});
    }
    catch(e) {

    }
    let result = await config.flightSuretyData.isFundedAirline(config.owner); 

    // ASSERT
    assert.equal(result, false);

  });

  it('Airline can be funded with 10 or more ether only', async () => {
    
    // ARRANGE
    const fee = web3.utils.toWei('10',"ether");

    // ACT
    try {
        await config.flightSuretyApp.fundAirline(config.owner,{ from: config.owner, value: fee, gas: 6721900});
    }
    catch(e) {
console.log(e);
    }
    let result = await config.flightSuretyData.isFundedAirline(config.owner); 

    // ASSERT
    assert.equal(result, true);

  });
 

  
  it('Funded Airline can register other airline', async () => {
    
    // ARRANGE
    const secondAirline = config.testAddresses[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline("Indigo Airlines",secondAirline,{from: config.owner, gas: 6721900});
    }
    catch(e) {
console.log(e);
    }
    
    let result = await config.flightSuretyApp.isAirlineRegistered.call(secondAirline); 
    // ASSERT
    assert.equal(result, true);

  });

  it('If registered Airlines are 4, then further airline registration require voting.', async () => {
    
    // ARRANGE
    const thirdAirline = config.testAddresses[3];
    const fourthAirline = config.testAddresses[4];
    const fifthAirline = config.testAddresses[5];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline("Indigo Airlines",thirdAirline,{from: config.owner, gas: 6721900});
        await config.flightSuretyApp.registerAirline("Indigo Airlines",fourthAirline,{from: config.owner, gas: 6721900});
        await config.flightSuretyApp.registerAirline("Indigo Airlines",fifthAirline,{from: config.owner, gas: 6721900});
    }
    catch(e) {
         console.log(e);
    }
    
    let resultthirdAirline = await config.flightSuretyApp.isAirlineRegistered.call(thirdAirline); 
    let resultFourthAirline = await config.flightSuretyApp.isAirlineRegistered.call(fourthAirline); 
    let resultFifthAirline = await config.flightSuretyApp.isAirlineRegistered.call(fifthAirline); 
    
    
    // ASSERT
    assert.equal(resultthirdAirline, true, "Third Airline Registered Succesfully.");
    assert.equal(resultFourthAirline, true, "Fourth Airline Registered Succesfully.");
    assert.equal(resultFifthAirline, false, "Fifth airline should not registered and would require voting.");

  });

  it('Fifth airline waiting to be registered require atleast 2 votes to be registred', async () => {
    
    // ARRANGE
    const thirdAirline = config.testAddresses[3];
    const fifthAirline = config.testAddresses[5];
    
    const fee = web3.utils.toWei('10',"ether");

    // ACT
    try {
      //Fund second airline first to participate in voting
        await config.flightSuretyApp.fundAirline(thirdAirline,{ from: thirdAirline, value: fee, gas: 6721900});
        await config.flightSuretyApp.voteAirline(fifthAirline,{from: thirdAirline, gas: 6721900});
    }
    catch(e) {
       console.log(e);
    }
    
    let resultFifthAirline = await config.flightSuretyApp.isAirlineRegistered.call(fifthAirline);
    // ASSERT
    assert.equal(resultFifthAirline, true, "Fifth airline should be registsred after enough vote recieved.");

  });

  it('(Purchase insurence), Pessanger can purchase insurence by paying anything but less then 1 ether', async () => {
    
    // ARRANGE
    var error = false;
    
    const insurenceAmount = web3.utils.toWei('0.5',"ether");
    const flightName = "Indian Airlines";
    const timeStamp = 20210624;
    const pessangerAddress = config.testAddresses[6];

    // ACT
    try {
      //Fund second airline first to participate in voting
        await config.flightSuretyApp.buyInsurence(flightName,config.owner,timeStamp,{ from: pessangerAddress, value: insurenceAmount, gas: 6721900});
    }
    catch(e) {
       console.log(e);
       error = true;
    }
    
    // ASSERT
    assert.equal(error, false, "Pessanger should be able to buy insurence for registered airline.");

  });
  

});
