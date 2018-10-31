({
    changedModel : function(component, context) {
        switch(context.currentSlide) {
            case 0:
                component.set('v.model', 'Flint');
                break;
            case 1:
                component.set('v.model', 'Flare');
                break;
            default:
                component.set('v.model', 'Flash');
                break;
        }
    },
    
    changeColor: function(paint, component) {
        console.log('changeColor: ' + paint);
        
        var oldPaint = component.get('v.paint');
        if (paint != oldPaint) {
            $A.util.removeClass(document.getElementById(oldPaint), 'selected');
        }
        
        component.set('v.paint', paint);
        $A.util.addClass(document.getElementById(paint), 'selected');
    }
})