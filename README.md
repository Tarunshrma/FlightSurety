# Fight Surety | Ethereum 

## Table of Contents
1. [General Info](#general-info)
2. [Design Diagrams](#design-diagrams)
3. [How to Run](#installation)
4. [Unit Tests](#unit-test)

### general-info
This is simplified version of Flight insurence solution using Blockchain technologies. This project is part of [Udacity Nanodegree program](https://andresaaap.medium.com/flightsurety-project-faq-udacity-blockchain-b4bd4fb03320).

Using this solution, Passengers can directly buy insurance for flight and can be paid into their account in case flight is delayed, without involvement of any third party insurance companies, banks etc. This solution will result in removal of middleman like insurance companies and results in faster insurance processing, less transaction fee and more trust between Airline companies and passengers.   


### design-diagrams
#### High Level Diagram
![Design Diagram](/design-diagrams/high-level-diagram.png)

#### Sequence Diagram
![Sequence Diagram](/design-diagrams/sequence-diagram.png)


### installation
A step by step series of examples that tell you have to get a development env running

Clone this repository:

```bash
git clone https://github.com/Tarunshrma/FlightSurety.git
```

Change directory to FlightSurety folder and install all requisite npm packages (as listed in package.json):

```bash
cd FlightSurety
npm install
```

Compile the smart contracts
```bash
truffle compile
```

Open the terminal and launch the local instance of blockchain to test your smart contracts. 
```bash
ganache-cli -a 20
```
This command will launch the local blockchain at http://127.0.0.1:8545/ with 20 test accounts and private keys. You can use those accounts to test and execute the smart contracts locally without deploying it to TestNet or MainNet. 
![Truffle Develop Info](/assets/local-blockchain.png)

Run Unit Test Cases
```bash
truffle test
```
![Unit Test Case](/assets/unit-tests.png)

Deploy Smart Contracts To Local Blockchain Instance
```bash
truffle migrate --network development
```
![Contract Deployment](/assets/contract-deployment-1.png)
![Contract Deployment](/assets/contract-deployment-2.png)

### FrontEnd
Deploy front end using below command
```bash
npm run dapp
```
![Running Front End](/assets/run-frontend-flight-surety.png)

![Front End](/assets/front-end.png)

### Oracles
Deploy nodejs server to register oracles.
```bash
npm run server
```
![Running Server](/assets/oracles.png)