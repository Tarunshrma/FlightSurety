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
git clone https://github.com/Tarunshrma/coffee-supply-chain-ethereum.git
```

Change directory to coffee-supply-chain-ethereum folder and install all requisite npm packages (as listed in package.json):

```bash
cd coffee-supply-chain-ethereum
npm install
```

Compile the smart contracts
```bash
truffle compile
```

Launch the local instance of blockchain to test your smart contracts. 
```bash
truffle develop
```
This command will launch the local blockchain at http://127.0.0.1:9545/ with test accounts and private keys. You can use those accounts to test and execute the smart contracts locally without deploying it to TestNet or MainNet. 
![Truffle Develop Info](/assests/truffle-develop-command.png)

Run Test Cases
```bash
truffle test
```
![Unit Test Case](/assests/test-case-suite.png)

Run front end
```bash
npm run dev
```
![Unit Test Case](/assests/run-frontend.png)

### FrontEnd
![Front End](/assests/front-end.png)