({
    getColorHex : function(input) {
        try {        
            input = input.replace(/\W/g, "");
            if (input.length == 6) {
                if (input == "SPDRMN") {
                    return "#FF0101";
                } else {
                    return "#" + input;
                }
            }
        } catch(e) {}
        return "#FFFFFF";
    },
    
    getColorCode : function(input) {
        try {        
            input = input.replace(/\W/g, "");
            if (input.length == 6) {
                return input;
            }
        } catch(e) {}
        return "FFFFFF";
    }
})