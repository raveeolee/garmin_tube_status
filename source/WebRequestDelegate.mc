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
    var max = 8;
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
    
    function onBack()
    {
    	return true;
    }
   
    
   //function onNextPage() {
    //	System.println("NEXT PAGE");
      //  return true;
   //}
    
    function onNextPageP() {
    	if (mResults != null) {
    		if (max > mResults.size()) {
    			max = mResults.size();
    		}
    		notify.invoke(mResults.slice(shift, max));
    		shift += max;
    		max   += max;
    	}
    }
    
    function onPreviousPageP() {
    	if (shift != 0) {
    		shift -= max;
    		max   -= max;
    		
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
        
        shift = 0;
        max = 8;
        mResults = null;
		
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
        if (evt.getKey() == Ui.KEY_DOWN) {
        	System.println("KEY DOWN");
            onNextPageP();
            System.println("Out");
            return true;
        } 
        
        if (evt.getKey() == Ui.KEY_UP) {
        	System.println("KEY UP");
            onPreviousPageP();
            return true;
        }

        return true;
    }
}