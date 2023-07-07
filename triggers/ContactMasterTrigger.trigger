trigger ContactMasterTrigger on Contact  (
    before insert, after insert,
    before update, after update,
    before delete, after delete, after undelete) {

    // check if it is a before event
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            // logic
        }

        if (trigger.isUpdate) {
            // logic
        }

        if (trigger.isDelete) {
            // logic
        }
    }

    // check if it is an after event
    if (trigger.isAfter) {
        if (trigger.isInsert) {            
            ContactHandler.assignPermissionSet(Trigger.new);
        }

        if (trigger.isUpdate) {
            // logic
        }

        if (trigger.isDelete) {
            // logic
        }

        if (trigger.isUndelete) {
            // logic
        }
    }
}