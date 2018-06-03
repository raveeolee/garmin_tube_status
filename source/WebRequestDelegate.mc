//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class WebRequestDelegate extends Ui.BehaviorDelegate {
    var notify;
    var shift = 0;
    var step = 8;
    var max = step;
    var mResults;

    // Handle menu button press
    function onMenu() {
        makeRequest();
        return true;
    }

    function onSelect() {
        makeRequest();
        return true;
    }
 
    function onNextPageP() {    	
    	if (mResults != null) {
    		var tMax = max;
    		if (max > mResults.size()) {
    			tMax = mResults.size();
    		}
    		
    		notify.invoke(mResults.slice(shift, tMax));
    		
    		if (max < mResults.size()) {
    			shift += step;
    			max += step;
    		}
    		
    		//shift += step;
    		//max   += step;
    	}
    }
    
    function onPreviousPageP() {
    	if (shift > 0) {
    		shift -= step;
    		max   -= step;
    		
    		System.println("shift: " + shift + " max: " + max);
    		notify.invoke(mResults.slice(shift, max));
    	}
    }
    
    // Set up the callback to the view
    function initialize(handler) {
        Ui.BehaviorDelegate.initialize();
        notify = handler;
    }

    function makeRequest() {
        notify.invoke("Requesting\nTFL Status");
        
        resetState();
		
        Comm.makeWebRequest(//url, parameters, options, responseCallback) (
            "https://api-neon.tfl.gov.uk/Line/Mode/tube/Status?detail=false",
            {
            },
            {
                "Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED,
                :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            method(:onReceive)
        );
    }

    function resetState() {
    	shift = 0;
    	max = 8;
    	mResults = null;
    }

    // Receive the data from the web request
    function onReceive(responseCode, data) {
        if (responseCode == 200) {
            notify.invoke("TFL status received");
            var results = parseLines(data);
            
            //System.println(data);
            //notify.invoke(results);
            
            onNextPageP();
            
        } else {
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
    
    function parseLines(tubesLinesData) {
        var results = [];
        for( var i = 0; i < tubesLinesData.size(); i++ ) {
            var item = tubesLinesData[i];
            var name = item.get("name");
            var status = item.get("lineStatuses")[0].get("statusSeverityDescription");
            
            //System.println(name + " | " + status);
            results.add(name + " | " + status +  "\n");
        }
        
        //System.println(results);
        mResults = results;
        return results;
        // notify.invoke(results.slice());
    }
    
    function onKey(evt) {
    	var view = new WebRequestView();
        if (evt.getKey() == Ui.KEY_DOWN) {
        	System.println("KEY DOWN");
            //onNextPageP();
            // System.println("Out");
           
           onNextPageP();
           Ui.pushView(view, self, Ui.SLIDE_IMMEDIATE);           	    
           return true;
        } 
        
        if (evt.getKey() == Ui.KEY_UP) {
        	System.println("KEY UP");
            onPreviousPageP();
            Ui.pushView(view, self, Ui.SLIDE_IMMEDIATE);
            return true;
        }

        return true;
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
    //function onBack();

    // When a next mode behavior occurs, onNextMode() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onNextMode() {}

    // When a previous mode behavior occurs, onPreviousMode() is called.
    // @return [Boolean] true if handled, false otherwise
    //function onPreviousMode() {}
}