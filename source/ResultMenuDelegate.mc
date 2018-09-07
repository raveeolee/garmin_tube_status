//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class ResultMenuDelegate extends Ui.MenuInputDelegate {	
	hidden var _results;
	hidden var _allLines;
	
	const _symbols = [
	    :symbol0,
	    :symbol1,
	    :symbol2,
	    :symbol3,
	    :symbol4,
	    :symbol5,
	    :symbol6,
	    :symbol7,
	    :symbol8,
	    :symbol9,
	    :symbol10,
	    :symbol11,
	    :symbol12,
	    :symbol13,
	    :symbol14,
	    :symbol15
	];

	// Set up the callback to the view
    function initialize(results, allLines) {   
    	Ui.MenuInputDelegate.initialize();
    	
    	self._results = results;
    	self._allLines = allLines;
    }
    
    function onMenuItem(item) {
        System.println(item);
        
        if (item == :exit) {
        	System.exit();
        }
        
        else if (item == :details) {
        	switchToDetailsView();
        }
    }  
    
    function switchToDetailsView() {
    	var menu = new Ui.Menu();            	
    	var delegate = new DetailedResultMenuDelegate(_results, _allLines);
    	
    	menu.setTitle("TFL status");
    	menu.addItem("< Back",  :back);
    	    	
    	for (var n = 0; n < _allLines.size(); n++) {
    		menu.addItem(_allLines[n], _symbols[n]);
    	}
    	    	
    	menu.addItem("Exit",    :exit);   	
    	  	
    	Ui.pushView(menu, delegate, Ui.SLIDE_IMMEDIATE);    	
    }  
}