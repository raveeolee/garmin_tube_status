//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class DetailedResultMenuDelegate extends Ui.MenuInputDelegate {	
	hidden var _results;
	hidden var _allLines;

    function initialize(results, allLines) {   
    	Ui.MenuInputDelegate.initialize();
    	
    	self._results = results;
    	self._allLines = allLines;
    }
    
    function onMenuItem(item) {
        if (item == :exit) {
        	System.exit();
        }
        
        else if (item == :back) {
        	Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
    }    
}