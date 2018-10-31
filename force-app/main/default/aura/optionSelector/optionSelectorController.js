({
	doInit : function(component, event, helper) {
		var vehicle = component.get('v.vehicle');
        console.log('Vehicle: ' + JSON.stringify(vehicle));
        console.log('Battery: ' + vehicle.Battery__c);
	},
    
    onBatterySelect : function(component, event, helper) {
        console.log('Battery selected: ' + event.target.id);
        console.log('Battery value: ' + event.target.value);
    }
})