
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

        // User-submitted transaction
        // DOM.elid('submit-oracle').addEventListener('click', () => {
        //     let flight = DOM.elid('flight-number').value;
        //     // Write transaction
        //     contract.fetchFlightStatus(flight, (error, result) => {
        //         display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
        //     });
        // })

        
    
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







