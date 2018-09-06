//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class ResultsPageDelegate extends Ui.BehaviorDelegate {
	hidden var mResults;
	hidden var mNotify;
    hidden var mShift = 0;
    hidden var mStep = 8;
    hidden var mMax = mStep;
    hidden var mNext;

	// Set up the callback to the view
    function initialize(results, shift, step) {   
    	Ui.BehaviorDelegate.initialize();
    	mResults = results;  	
    	mShift = shift;
    	mStep = step;  
    	
    	showNextPage(results);
    }
    
    function onKey(evt) {
        if (evt.getKey() == Ui.KEY_DOWN) {
        	System.println("KEY DOWN");
                      
           if (mResults != null) {
           		showNextPage(mResults);
           }  
                    	    
           return true;
        } 
        
        if (evt.getKey() == Ui.KEY_UP) {
        	System.println("KEY UP");
            showPreviousPage();
            return true;
        }
   
        return true;
    }
    
    function showNextPage(results) {
    	if (results != null) {
    		var tMax = mMax;
    		if (mMax > results.size()) {
    			tMax = results.size();
    		}
    		
    		Ui.pushView(new ResultsView(results.slice(mShift, tMax)), self, Ui.SLIDE_IMMEDIATE);
    	
    		if (mMax < results.size()) {
    			mShift += mStep;
    			mMax += mStep;
    		}
    	}
    }   
    
    function onBack() {
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
    	return true;
    } 
    
    function showPreviousPage() {
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
}