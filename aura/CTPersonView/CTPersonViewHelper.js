({
    updateStatus: function (component) {
        const recordId = component.get("v.recordId");

        const action = component.get("c.updateHealthStatus");
        action.setParams({
            personId: recordId
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                this.showToast("Sucess", "Person Health Status Updated", "Success");
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function (title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
})