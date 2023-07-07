trigger RentalAgreementMasterTrigger on Rental_Agreement__c (
    before insert, after insert,
    before update, after update,
    before delete, after delete, after undelete) {

    // check if it is a before event
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            //RentalAgreementHandler.preventTenantWithOutstandingBalance(Trigger.new);
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
            RentalAgreementHandler.updateRentalStatus(Trigger.new);
            RentalAgreementHandler.createStatement(Trigger.new);
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