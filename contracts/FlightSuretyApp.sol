pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";



/************************************************** */
/* Interface for data contract                      */
/************************************************** */

contract FlightSuretyData{

    function isOperational() public view returns(bool);

    function setOperatingStatus(bool mode) external;

    function setAuthorizeContract(address contractAddress) external;

    function removeAuthorizeContract(address contractAddress) external;

    function registerAirline(string name, address airlineAddress, bool votingRequired) public;

    function fundAirline(address airlineAddress,uint256 amount) external;

    function buy(bytes32 flightKey, address pessangerAddress, uint256 insuredAmount) external;

    function creditInsurees(bytes32 flightKey) external;

    function withdrawCreditedAmount(address pessangerAddress) external returns(uint256);

    function getRegisteredAirlinesCount() view public returns(uint256);

    function isRegisteredAirline(address airlineAddress) view public returns(bool);

    function isFundedAirline(address airlineAddress) view public returns(bool);

    function isRegisterationPendingAirline(address airlineAddress) view public returns(bool);

    function addAirlineToRegistrationQueue(string name, address airlineAddress) external;

    function voteAirlineForRegistration(address airlineAddress) external returns (uint voteCount); 
}
/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    string constant private DEFAULT_AIRLINES = "Indian Airlines"; 
    uint256 constant private MIN_AIRLINES_COUNT = 4; 
    uint8 constant private MIN_AIRLINES_FUND_REQUIRED = 10; 

    address private contractOwner;          // Account used to deploy contract
    FlightSuretyData private  flightSuretyData;


 
    /********************************************************************************************/
    /*                                       Events                                             */
    /********************************************************************************************/
   event RegisterAirline(address airlineAddress);

   event AirlineFunded(address airlineAddress);

   event AirlinePendingVoting(address airlineAddress);

   event AirlineVoted(address airlineAddress, uint256 voteCount);

   event InsurencePurchased(string flightName, uint256 amount);

   event FlightDelayed(string flightName);

   event AmountWithdrawn(address pessangerAddress, uint256 claimAmount);
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
         // Modify to call data contract's status
        require(flightSuretyData.isOperational(), "Contract is currently not operational");  
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

        /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireValidAddress(address addressToCheck) 
    {
         // Modify to check if address is valid
        require(addressToCheck != address(0), "Address is invalid");  
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


    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor
                                (
                                    address dataContractAddress
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        flightSuretyData = FlightSuretyData(dataContractAddress);
        _registerAirline(DEFAULT_AIRLINES,contractOwner,false);
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() 
                            public
                            view 
                            returns(bool) 
    {
        return flightSuretyData.isOperational();  // Modify to call data contract's status
    }

    /********************************************************************************************/
    /*                                       Private Functions                                */
    /********************************************************************************************/
    function _registerAirline
                            (
                                string airlineName,
                                address airlineAddress,
                                bool votingRequired
                            )
                            private
                            returns(bool success)
    {
        flightSuretyData.registerAirline(airlineName,airlineAddress,votingRequired);

        emit RegisterAirline(airlineAddress);

        success = true;

    }


    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

  
   /**
    * @dev Add an airline to the registration queue
    *
    */   
    function registerAirline
                            (
                                string airlineName,
                                address airlineAddress   
                            )
                            external
                            requireIsOperational
                            returns(bool)
    {
        //Airline should be registred already.
        require(!flightSuretyData.isRegisteredAirline(airlineAddress), "Airline already registered.");
        
        //Airline trying to add other airline should be registred and funded.
        require(flightSuretyData.isRegisteredAirline(msg.sender), "Airline trying to add other airline is not registered");
        require(flightSuretyData.isFundedAirline(msg.sender), "Airline trying to add other airline does not have enough funds");

        //Check if airline is already in queue for registration 
        require(!flightSuretyData.isRegisterationPendingAirline(airlineAddress), "Airline is already in queue for registeration.");


        //If there are less then MIN_AIRLINES_COUNT regisered then no voting required and any already registered airline can register other airline
        if(flightSuretyData.getRegisteredAirlinesCount() < MIN_AIRLINES_COUNT){

            //If above condition met, then directly register the airlines without any voting mechenism.
            _registerAirline(airlineName,airlineAddress,false);
            return (true);
        }

      //Add airline to queue for voting.
      flightSuretyData.addAirlineToRegistrationQueue(airlineName,airlineAddress);
      emit AirlinePendingVoting(airlineAddress);
        return (false);
    }

    /** 
    * @dev Fund an airline to participate in contract execution.
    *
    */  
    function fundAirline
                                (
                                    address airlineAddress
                                )
                                payable
                                external
                                requireIsOperational
    {
        //First check if flight to be funded is registered.
        //then check if already funded 
        //if both conditions meet i.e. already registsred and not funded then check for min. fund required.
        require(flightSuretyData.isRegisteredAirline(airlineAddress), "Airline trying to fund is not registered.");
        require(flightSuretyData.isFundedAirline(airlineAddress) == false, "Airline trying to add fund already funded.");
        require(msg.value > MIN_AIRLINES_FUND_REQUIRED , "Not enough ether provided to fund the airline.");

        flightSuretyData.fundAirline(airlineAddress, msg.value);

        emit AirlineFunded(airlineAddress);
    }


   /**
    * @dev Vote an airline for registration... returns the votes obtained so far, if enough votes then register the airlines.
    * TODO: Add logic to check if this user already voted for this airlines.
    */  
    function voteAirline(address airlineAddress) external requireIsOperational returns (uint voteCount) {
        //Check if airline is already in queue for registration and registered and funded to participate in voting.
        require(flightSuretyData.isRegisterationPendingAirline(airlineAddress), "Airline not in queue and is not eligible for voting.");
        require(flightSuretyData.isRegisteredAirline(msg.sender), "Airline trying to vote other airline is not registered");
        require(flightSuretyData.isFundedAirline(msg.sender), "Airline trying to vote other airline does not have enough funds");

        voteCount = flightSuretyData.voteAirlineForRegistration(airlineAddress);

        emit AirlineVoted(airlineAddress, voteCount);

        return (voteCount);
    }

   /**
    * @dev buy insurence for flight.
    *
    */  
    function buyInsurence
                                (
                                    string flightName,
                                    address airlineAddress,
                                    uint256 timestamp
                                )
                                external
                                payable
                                requireIsOperational
                                requireValidAddress(airlineAddress)
    {
        require(flightSuretyData.isRegisteredAirline(airlineAddress), "Airline is not registered");
        require(flightSuretyData.isFundedAirline(airlineAddress), "Airline does not have enough funds");
        require(msg.value > 0 ether, "Please provide ethers to purchase insurence");
        require(msg.value < 1 ether, "Provide less then 1 ether.");

       bytes32 flightKey = getFlightKey(airlineAddress,flightName,timestamp);

       flightSuretyData.buy(flightKey, msg.sender, msg.value);

       emit InsurencePurchased(flightName,msg.value);
    }
    
   /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus
                                (
                                    address airlineAddress,
                                    string memory flightName,
                                    uint256 timestamp,
                                    uint8 statusCode
                                )
                                internal
    {
        //If flight is delayed due to airline fault.. then credit the insuree with 1.5 of original amount.
        if(statusCode == STATUS_CODE_LATE_AIRLINE)
        {
            emit FlightDelayed(flightName);

            bytes32 flightKey = getFlightKey(airlineAddress,flightName,timestamp);
            flightSuretyData.creditInsurees(flightKey);


        }


    }


    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airlineAddress,
                            string flight,
                            uint256 timestamp                            
                        )
                        external
    {
        require(flightSuretyData.isRegisteredAirline(airlineAddress), "Airline is not registered");

        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airlineAddress, flight, timestamp));
        oracleResponses[key] = ResponseInfo({
                                                requester: msg.sender,
                                                isOpen: true
                                            });

        emit OracleRequest(index, airlineAddress, flight, timestamp);
    }

    function withdrawBalance(address pessangerAddress) external{
        require(pessangerAddress != address(0), "Provide valid address.");
        uint256 creditAmount = flightSuretyData.withdrawCreditedAmount(pessangerAddress);

        emit AmountWithdrawn(pessangerAddress, creditAmount);
    }


// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);


    // Register an oracle with the contract
    function registerOracle
                            (
                            )
                            external
                            payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
                                        isRegistered: true,
                                        indexes: indexes
                                    });
    }

    function getMyIndexes
                            (
                            )
                            view
                            external
                            returns(uint8[3])
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }




    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            string flight,
                            uint256 timestamp,
                            uint8 statusCode
                        )
                        external
    {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }

    // function checkBalance
    //                         (
    //                             address pessangerAddress
    //                         )
    //                         view
    //                         external
    //                         returns(uint256)
    // {
    //     require(pessangerAddress != address(0), "Provide valid pessanger address");

        
    // }


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

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (                       
                                address account         
                            )
                            internal
                            returns(uint8[3])
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   
