
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
    
        // Register Airlines
        DOM.elid('submit-airline').addEventListener('click', () => {
            let airlineName = DOM.elid('airline-name').value;
            let airlineAddress = DOM.elid('airline-address').value;
            // Write transaction
            contract.registerAirline(airlineName,airlineAddress, (error, result) => {
                if(error){
                    console.log(error);
                    alert(error);
                }else{
                    console.log("Airline Registerd sucessfully..");
                    alert("Airline Registerd sucessfully..");
                }
                
                //display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        //Fund Airlines
        DOM.elid('fund-airlines').addEventListener('click', () => {
            let airlineAddress = DOM.elid('airline-fund-address').value;
            // Write transaction
            contract.fundAirline(airlineAddress, (error, result) => {
                if(error){
                    console.log(error);
                    alert(error);
                }else{
                    console.log("Airline funded sucessfully..");
                    alert("Airline funded sucessfully..");
                }
                
                //display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        //Vote For Airlines
        DOM.elid('vote-airlines').addEventListener('click', () => {
            let airlineAddress = DOM.elid('airline-fund-address').value;
            // Write transaction
            contract.voteAirline(airlineAddress, (error, result) => {
                if(error){
                    console.log(error);
                    alert(error);
                }else{
                    console.log("Airline voted sucessfully.." + result);
                    alert("Airline vote sucessfully: " + result);
                }
                
                //display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        //Buy Insurence
        DOM.elid('submit-flight-insurence').addEventListener('click', () => {
            let flightName = DOM.elid('flight-name').value;
            let airlineAddress = DOM.elid('insurence-airline-name').value;
            let timestamp = DOM.elid('flight-timestamp').value;
            let insuredAmount = DOM.elid('insurence-amount').value;
            // Write transaction
            contract.buyInsurence(flightName,airlineAddress,timestamp,insuredAmount, (error, result) => {
                if(error){
                    console.log(error);
                    alert(error);
                }else{
                    console.log("Flight Insured Succesfully" + result);
                    alert("Flight Insured Succesfully: " + result);
                }
                
                //display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flightName = DOM.elid('flight-name').value;
            let airlineAddress = DOM.elid('insurence-airline-name').value;
            let timestamp = DOM.elid('flight-timestamp').value;

            // Write transaction
            contract.fetchFlightStatus(flightName,airlineAddress,timestamp, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        DOM.elid('check-balance').addEventListener('click', () => {
            let pessangerAddress = DOM.elid('passanger-address').value;

            // Write transaction
            contract.checkPessangerBalance(pessangerAddress, (error, result) => {
                if(error){
                    console.log(error);
                    alert(error);
                }else{
                    DOM.elid('passanger-balance').innerText  = result + ' ether';
                }
                
            });
        })

        DOM.elid('withdraw-balance').addEventListener('click', () => {
            let pessangerAddress = DOM.elid('passanger-address').value;

            contract.withdrawBalance(pessangerAddress, (error, result) => {
                if(error){
                    console.log(error);
                    alert(error);
                }else{
                    alert("Withdrawal Succesfully: " + result);
                }
            });
        });
    });
})();


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}







