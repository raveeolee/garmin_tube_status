//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class WebRequestDelegate extends Ui.BehaviorDelegate {
    var notify;

    // Handle menu button press
    function onMenu() {
        makeRequest();
        return true;
    }

    function onSelect() {
        makeRequest();
        return true;
    }
    
    // Set up the callback to the view
    function initialize(handler) {
        //Ui.BehaviorDelegate.initialize();
        Ui.View.initialize();
        notify = handler;
    }

    function makeRequest() {
        notify.invoke("Requesting\nTFL Status");
		
        Comm.makeWebRequest(//url, parameters, options, responseCallback) (
            "https://api-neon.tfl.gov.uk/Line/Mode/tube,dlr,overground/Status?detail=false",
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
            parseLines(data);
            
            //System.println(data);
            //notify.invoke(data.toString());
            
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
        notify.invoke(results);
    }
}