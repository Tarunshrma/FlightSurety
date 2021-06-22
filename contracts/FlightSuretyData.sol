pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;
    using SafeMath for uint;

     /********************************************************************************************/
    /*                                       Structs to store data                                     */
    /********************************************************************************************/
    struct Airline{
        string name;
        address airlineAddress;
        bool isFunded;
        bool isRegistered; //If amoung first found airlines then on adding it will directly registered else will require consensus mechenism.
        bool isSeedAirline; //If among initial four airlines.
        uint voteCount; //Check the voting, only matter if isRegistered is false; 
    }

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;        
        address airline;
    }

    struct InsuredPessanger{
        address pessangerAddress; //Pessanger Address
        mapping (bytes32 => uint256) insuredFlights; //List of flights insured by pessanger.
        uint256 claimAmount;  // Amount that can be claimed by pessanger and withdraw to his/her wallet
    }


    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    uint256 private totalAvailableFunds;                                //Total available funds
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    uint256  registeredAirlineCount = 0;                           //Keep track of total number of registered airlines... to avoid looping

    mapping (address => Airline)  RegisteredAirlines;            // Registered Airlines
    mapping (address => Airline) private PendingRegistrationAirlines;   //Airlines in queue to be registered
    mapping (address => bool) authorizeContracts;




    mapping(bytes32 => Flight) private flights;
    InsuredPessanger[] private insuredPessangers;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    event AirlineDataSaved(address airlineAddress, uint256 airlineCount);

    event AirlineDataSavedInQueueForRegistration(address airlineAddress);

    event buyInsurenceDataSaved(bytes32 flightKey,uint256 totalInsuredPessangerCount,uint256 totalAvailableFunds);

    event  ExistingPessangerCheckIfFlightAlreadyInsured(address pessangerAddress,uint256 index,uint256 insuredFlightAmount);

    event  ExistingPessangerNewFlightInsurence(address pessangerAddress);

    event AmountCreditedToPessangerForDelayedFlight(address pessangerAddress,uint256 orginalInsurenceAmount,uint256 claimAmount);   

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

        /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireAuthorizeContract(address contractAddress)
    {
        require(authorizeContracts[contractAddress], "Caller is not authorized");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/


   /**
    * @dev Add an authorize contract
    *      Can only be called by contract owner
    *
    */  
    function setAuthorizeContract(address contractAddress) external requireContractOwner
    {
        authorizeContracts[contractAddress] = true;
    } 

       /**
    * @dev Remove an authorize contract
           Should have registered earlier
    *      Can only be called by contract owner
    *
    */  
    function removeAuthorizeContract(address contractAddress) 
    external 
    requireAuthorizeContract(contractAddress)
    requireContractOwner
    {
        delete authorizeContracts[contractAddress];
    } 

   /**
    * @dev Add an airline to the registration
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                string name,
                                address airlineAddress,
                                bool votingRequired   
                            )
                            public
                            //requireAuthorizeContract(msg.sender)
                            requireIsOperational
                            
    {

        //Create Airline object
        RegisteredAirlines[airlineAddress] = Airline({
            airlineAddress : airlineAddress,
            name : name,
            isFunded : false,
            isRegistered : true,
            isSeedAirline : !votingRequired,
            voteCount : 0
        });

        //Increase the airline count
        registeredAirlineCount = registeredAirlineCount.add(1);

        emit AirlineDataSaved(airlineAddress,registeredAirlineCount);
    }

    /**
    * @dev Add an airline to the registration queue. Voting required to add it.
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function addAirlineToRegistrationQueue
                            (
                                string name,
                                address airlineAddress
                            )
                            external
                            //requireAuthorizeContract(msg.sender)
                            requireIsOperational
                            
    {

        //Create Airline object
        PendingRegistrationAirlines[airlineAddress] = Airline({
            airlineAddress : airlineAddress,
            name : name,
            isFunded : false,
            isRegistered : false,
            isSeedAirline : false,
            voteCount : 1  // Initialize vote count to one.. whoever adding it queue is by default giving it's vote.
        });

        emit AirlineDataSavedInQueueForRegistration(airlineAddress);
    }

        /**
    * @dev Add an airline to the registration queue. Voting required to add it.
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function voteAirlineForRegistration
                            (
                                address airlineAddress
                            )
                            external
                            //requireAuthorizeContract(msg.sender)
                            requireIsOperational
                            returns (uint voteCount)
                            
    {
         PendingRegistrationAirlines[airlineAddress].voteCount = PendingRegistrationAirlines[airlineAddress].voteCount.add(1);
         voteCount = PendingRegistrationAirlines[airlineAddress].voteCount;

         //If votes are more then equal to half of already registred airline then register the airlines reomve it from queue
         if (voteCount >= registeredAirlineCount.div(2)){
            registerAirline(PendingRegistrationAirlines[airlineAddress].name, airlineAddress, true);
            delete PendingRegistrationAirlines[airlineAddress];
         }

         return (voteCount);
    }


    /**
    * @dev Fund an airline to be operational
    *      Can only be called from FlightSuretyApp contract
    *      Can only be called if operational.
    */   
    function fundAirline
                            (
                                address airlineAddress,
                                uint256 amount
                            ) 
                            external
                            //requireAuthorizeContract(msg.sender)
                            requireIsOperational
    {
         RegisteredAirlines[airlineAddress].isFunded = true; 
         totalAvailableFunds = totalAvailableFunds.add(amount); //Add the fund to pool of funds 
    }

   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (  
                                bytes32 flightKey,
                                address pessangerAddress,
                                uint256 insuredAmount                           
                            )
                            external
                            requireIsOperational
                            //requireAuthorizeContract(msg.sender)
    {

    //Check if flight is already purchased by this pessanger, if yes then revert the transation
    uint256 index = pessangerInsured(pessangerAddress);

    if(index != 999){

       emit  ExistingPessangerCheckIfFlightAlreadyInsured(pessangerAddress, index, insuredPessangers[index].insuredFlights[flightKey]);

       //Get the already insured pessanger and add the flight key to list of insured flights.
       require(insuredPessangers[index].insuredFlights[flightKey] == 0,"Pessanger has already insured this flight");
       insuredPessangers[index].insuredFlights[flightKey] = insuredAmount;

       emit  ExistingPessangerNewFlightInsurence(pessangerAddress);

    }else{
        //Add new entry to insured pessanger.
        insuredPessangers.push(
            InsuredPessanger({
                pessangerAddress : pessangerAddress,
                //insuredFlights : ,
                claimAmount : 0
            }));

            insuredPessangers[insuredPessangers.length - 1].insuredFlights[flightKey] = insuredAmount;
    }

        totalAvailableFunds = totalAvailableFunds.add(insuredAmount); 

        emit  buyInsurenceDataSaved(flightKey,insuredPessangers.length,totalAvailableFunds);

    }


    function pessangerInsured(address pessangerAddress) internal returns(uint256 insuredPessangerIndex)
    {
        //Initialize to index not found
        insuredPessangerIndex = 999;


        for (uint i=0; i<insuredPessangers.length; i++) {

            if(pessangerAddress == insuredPessangers[i].pessangerAddress){
                insuredPessangerIndex = i;
                break;
            }

        }

        return (insuredPessangerIndex);
    }


    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                    bytes32 flightKey
                                )
                                external
    {
    //Check if flight is already purchased by this pessanger, if yes then revert the transation
        for (uint i=0; i<insuredPessangers.length; i++) {
            if(insuredPessangers[i].insuredFlights[flightKey] > 0){
                uint256 orginalInsurenceAmount = insuredPessangers[i].insuredFlights[flightKey];

                //Credit pessanger account with 2x of original insurence amount on stake
                insuredPessangers[i].claimAmount = insuredPessangers[i].claimAmount.add(orginalInsurenceAmount.mul(2));
                
                emit  AmountCreditedToPessangerForDelayedFlight(insuredPessangers[i].pessangerAddress,orginalInsurenceAmount,insuredPessangers[i].claimAmount);
            }

        }


    }

    event withdrawCreditedAmountEvent(uint256 lineNumber);

    function withdrawCreditedAmount(address pessangerAddress) external  payable returns(uint256){

        emit withdrawCreditedAmountEvent(383);

        uint256 index = pessangerInsured(pessangerAddress);
        
        emit withdrawCreditedAmountEvent(387);
        
        uint256 creditAmount = insuredPessangers[index].claimAmount;

        emit withdrawCreditedAmountEvent(391);

        require(index != 999,"Provided address is in records.. Please check insurence is purchased.");
        require(creditAmount > 0,"Pessanger does not have sufficient balance to withdraw");

        emit withdrawCreditedAmountEvent(396);

        pessangerAddress.transfer(creditAmount);

        emit withdrawCreditedAmountEvent(400);

        insuredPessangers[index].claimAmount = 0;

        emit withdrawCreditedAmountEvent(404);

        return creditAmount;
       
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    // function pay
    //                         (
    //                         )
    //                         external
    //                         pure
    // {
    // }



    /**
    * @dev Get registered airlines count.
    *
    */
    function getRegisteredAirlinesCount()
                        view
                        public
                        returns(uint256) 
    {
        return registeredAirlineCount;
    }

    /**
    * @dev Check if Airline is in queue for registeration (voting required). 
    *
    */
    function isRegisterationPendingAirline
                        (
                            address airlineAddress
                        )
                        view
                        public
                        returns(bool) 
    {
        return PendingRegistrationAirlines[airlineAddress].airlineAddress != address(0);
    }

    /**
    * @dev Check if this airline is registered. 
    *
    */
    function isRegisteredAirline
                        (
                            address airlineAddress
                        )
                        view
                        public
                        returns(bool) 
    {
        return RegisteredAirlines[airlineAddress].isRegistered;
    }

    /**
    * @dev Check if this airline is funder. 
    *
    */
    function isFundedAirline
                        (
                            address airlineAddress
                        )
                        view
                        public
                        returns(bool) 
    {
        return RegisteredAirlines[airlineAddress].isFunded;
    }


// region Utility functions

   /**
    * @dev Generate unique flight key.
    *
    */
    function getFlightKey
                        (
                            address airline,
                            string flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // endregion

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        //fund();
    }


}

