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
        showAllLines();
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
		
        Comm.makeWebRequest(//url, parameters, options, responseCallback) (
            "https://api-neon.tfl.gov.uk/Line/Mode/tube/Status?detail=false",
            {
            },
            {
                "Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED,
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
            var results = parseLines(data);
            
            if (showDisrupted) {
            	mResults = filterDisrupted(results);
            }
            
            onNextPageP(results);
           	
        } else {
        	// TODO errors
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
        
    function onNextPageP(results) {    	
    	Ui.pushView(new ResultsView(results.slice(shift, step)), 
    				new ResultsPageDelegate(results, shift, step), Ui.SLIDE_IMMEDIATE); 
    }
    
    function filterDisrupted(results) {            
            var temp = [];
            for (var i = 0; i < results.size(); i++) {
                var item = results[i];                
            	if (item.find("Good") == null) {
            		temp.add(item);
            	}
            }	
            
            if (temp.size() == 0) {
            	temp = "Good Service on all lines";
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