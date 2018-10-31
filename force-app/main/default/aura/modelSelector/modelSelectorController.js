({
    doInit: function(component, event, helper) {
        setTimeout(function() {
            var paint = component.get('v.paint');
            helper.changeColor(paint, component);
        }, 100);
    },
    
    afterScriptsLoaded : function(component, event, helper) {
        new Siema({
            onChange: function() {
                helper.changedModel(component, this);
            }
        });
    },
    
    selectColor: function(component, event, helper) {
        helper.changeColor(event.target.id, component);
        console.log('Clicked: ' + event.target.id);
    }
})