({
    createRecord: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        const scope = component.get("v.scope")
        createRecordEvent.setParams({
            "entityApiName": scope === "person" ? "Person__c" : "Location__c"
        });
        createRecordEvent.fire();
    },

    doInit: function (component, event, helper) {
        helper.fetchStatusCount(component);
    }
})