({
    fetchLocationInformation: function (component, event, helper) {
        //Method definition goes here
        const recordId = component.get("v.recordId");
        const action = component.get("c.getLocationDetails");
        action.setParams({
            recordId
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                const resp = response.getReturnValue();
                // check if location found
                if (!resp || !resp.name) {
                    // Location not found
                    component.set("v.locationFound", false);
                    this.showToast("ERROR", "Please enter valid Location id", "error");
                } else {
                    // location found
                    component.set("v.locationFound", true);
                    component.set("v.locationInfo", resp);
                }
            } else {
                component.set("v.locationFound", false);
                this.showToast("ERROR", "Please enter valid Location id", "error");
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (title, message, type) {
        //Method definition goes here
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
});
