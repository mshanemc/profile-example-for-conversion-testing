({
    doInit : function(component, event, helper) {

    },
    recordLoaded: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "CHANGED") {
            component.find("recordEdit").reloadRecord();
        }
        var model = component.get("v.simpleRecord.Model__c");
        if (model == 'Flint') {
            component.set('v.photoUrl', $A.get('$Resource.flint'));    
        } else if (model == 'Flare') {
            component.set('v.photoUrl', $A.get('$Resource.flare'));
        } else {
            component.set('v.photoUrl', $A.get('$Resource.flash'));
        }
    },
    photoLoaded: function(component, event, helper) {
        var paintCode = helper.getColorHex(component.get("v.simpleRecord.Paint__c"));
        var photo = component.find("photo").getElement();
        console.log('photo:' + photo);
        photo.style.display = 'block';
        //photo.style.filter = 'hue-rotate(' + paintCode + 'deg)';
        var photo2 = component.find("photo2").getElement();
        //photo2.style.background = colorHex;
    },
    clickSpider: function(component, event, helper) { 
        console.log('Spider click');
        var photo2 = component.find("photo2").getElement();
        photo2.style.backgroundImage = "url(" + $A.get('$Resource.spiderBackground') + ")";
        photo2.style.backgroundSize = "cover";
        component.set("v.color", "SPDRMN");        
    },
    changeColorClick: function(component, event, helper) {
        var color = component.get('v.simpleRecord.Paint__c');
        component.set('v.color', color);
        var modal = component.find("modal").getElement();
        modal.style.display = 'block';        
    },
    colorClick: function(component, event, helper) {
        var value = event.currentTarget.dataset.value;
        component.set('v.color', value);
    },
    saveRecord: function(component, event, helper) {
        var color = component.get("v.color");
        component.set("v.simpleRecord.Paint__c", color);
        var modal = component.find("modal").getElement();
        modal.style.display = 'none';
        
        component.find("recordEdit").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": "Personalized color has been updated."
                });
                toastEvent.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    },
    cancel: function(component, event, helper) {
        var modal = component.find("modal").getElement();
        modal.style.display = 'none';
    }
})