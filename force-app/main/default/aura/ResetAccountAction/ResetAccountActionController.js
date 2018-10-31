({
    doInit : function(component, event, helper) {
        setTimeout(function() {
            var action = component.get("c.resetAccount");
            action.setParams({ recordId : component.get("v.recordId") });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Success: " + response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    console.log("INCOMPLETE");
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
            
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();            
        }, 1000);
    }
})