//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class WelcomePageDelegate extends Ui.BehaviorDelegate {
    hidden var notify;
    hidden var shift = 0;
    hidden var step = 8;
    hidden var max = step;
    hidden var showDisrupted = false;

    // Handle menu button press
    function onMenu() {
        showAllLines();
        return true;
    }

    function onSelect() {
        showDisruptedLines();
        return true;
    }
     
    // Set up the callback to the view
    function initialize(handler) {
        Ui.BehaviorDelegate.initialize();
        notify = handler;
    }

    function makeRequestTo(toDo) {
        notify.invoke("Requesting\nTFL Status");
        resetState();
        
        var headers = {
        	"Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
        };
		
        Comm.makeWebRequest(//url, parameters, options, responseCallback) (
            "https://api.tfl.gov.uk/Line/Mode/tube/Status",
            {
            	"detail" => false
            },
            {
                //"Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED,
                //"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON,
                :method => Comm.HTTP_REQUEST_METHOD_GET,
                :headers => headers,
                :responseType  => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            toDo
        );
    }
    
    function showAllLines() {
    	makeRequestTo(method(:onReceive));
    }
    
    function showDisruptedLines() {
    	showDisrupted = true;    	
    	makeRequestTo(method(:onReceive));
    }

    function resetState() {
    	shift = 0;
    	max = 8;
    }

    // Receive the data from the web request
    function onReceive(responseCode, data) {
        if (responseCode == 200) {
            notify.invoke("TFL status received");
            var allLines = parseLines(data);
            
            var disrupted = [];
            if (showDisrupted) {
            	disrupted = filterDisrupted(disrupted);
            }
                
            if (disrupted.size() > 0) {            
            	showResults(disrupted);
            } else {
            	showMessagePage(["Lines are OK"], allLines);
            }

        } else {
        	// TODO errors            
            var message = "Failed.\nError: " + responseCode.toString();            
            if (responseCode == -104) {
            	message += ".\nPlz, check connection";
            }            
            notify.invoke(message);
        }
    }
        
    function showResults(results) {    	
    	Ui.pushView(new ResultsView(results.slice(shift, step)), 
    				new ResultsPageDelegate(results, shift, step), Ui.SLIDE_IMMEDIATE); 
    }
    
    function showMessagePage(results, allLines) {
    	Ui.pushView(new ResultsView(results), new ResultsMessageDelegate(results, allLines), Ui.SLIDE_IMMEDIATE); 
    }
    
    function filterDisrupted(results) {            
            var temp = [];
            for (var i = 0; i < results.size(); i++) {
                var item = results[i];                
            	if (item.find("Good") == null) {
            		temp.add(item);
            	}
            }
            
            return temp;	
    }    
    
    function parseLines(tubesLinesData) {
        var results = [];
        for( var i = 0; i < tubesLinesData.size(); i++ ) {
            var item = tubesLinesData[i];
            var name = item.get("name");
            var status = item.get("lineStatuses")[0].get("statusSeverityDescription");
            
            results.add(name + " | " + status +  "\n");
        }
        return results;
    }
      
    
    // When a next page behavior occurs, onNextPage() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onNextPage() {
    //	onNextPageP();
        //return true;   
    //}

    // When a previous page behavior occurs, onPreviousPage() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onPreviousPage() {}

    // When a menu behavior occurs, onMenu() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onMenu() {}

    // When a back behavior occurs, onBack() is called.
    // @return [Boolean] true if handled, false otherwise
    function onBack() {
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
    	return true;
    }

    // When a next mode behavior occurs, onNextMode() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onNextMode() {}

    // When a previous mode behavior occurs, onPreviousMode() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onPreviousMode() {
    //	Ui.popView(Ui.SLIDE_IMMEDIATE);
    //}
}