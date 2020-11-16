({
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();  
    },
    handleSuccess : function(component, event, helper) {
        
        helper.showToast(component, {
            title: "Success",
            type: "success",
            message: "Record successfully saved!"
        });

        $A.get("e.force:closeQuickAction").fire();  
    }
})