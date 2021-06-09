pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

     /********************************************************************************************/
    /*                                       Structs to store data                                     */
    /********************************************************************************************/
    struct Airline{
        string name;
        address address;
        bool isFunded;
        bool isRegistered; //If amoung first found airlines then on adding it will directly registered else will require consensus mechenism.
        bool isSeedAirline; //If among initial four airlines.
        uint voteCount; //Check the voting, only matter if isRegistered is false; 
        uint256 fundAmount;
    }


    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    uint8 private registeredAirlineCount = 0;                           //Keep track of total number of registered airlines... to avoid looping

    mapping (address => Airline) private RegisteredAirlines;            // Registered Airlines
    mapping (address => Airline) private PendingRegistrationAirlines;   //Airlines in queue to be registered
    mapping (address => bool) authorizeContracts;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


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
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                string name,
                                string memory address,
                                bool votingRequired = true   
                            )
                            external
                            requireAuthorizeContract(msg.sender)
                            requireIsOperational
                            
    {
        //Create Airline object
        Airline memory airline = Airline();
        airline.address = address;
        airline.name = name;
        airline.isFunded = false;
        airline.isRegistered = true;
        airline.isSeedAirline = !votingRequired;
        airline.voteCount = 0;

        //Add it to queue and trigger an event to start processing queue 
        RegisteredAirlines[address] = airline;

//Increase the airline count
        registeredAirlineCount ++;

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
                            requireAuthorizeContract(msg.sender)
                            requireIsOperational
    {
         RegisteredAirlines[airlineAddress].isFunded = true; 
         RegisteredAirlines[airlineAddress].fundAmount = amount;
    }


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (                             
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            payable
    {
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }


    /**
    * @dev Get registered airlines count.
    *
    */
    function getRegisteredAirlinesCount
                        (
                        )
                        view
                        public
                        returns(uint) 
    {
        return registeredAirlineCount;
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

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

