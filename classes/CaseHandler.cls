public class CaseHandler {
    public static void updateMaintenance(List<Case> newCases, Map<Id, Case> oldMap) {
        Set<Id> rentalUnitIds = new Set<Id>();
        for (Case newCase : newCases) {
            // Filter Cases with Rental Units
            if (newCase.Rental_Unit__c != null) {
                rentalUnitIds.add(newCase.Rental_Unit__c);
            }
            // Covers if Rental Unit of Case was updated
            if (oldMap.containsKey(newCase.Id) && oldMap.get(newCase.Id).Status != 'Closed') {
                rentalUnitIds.add(oldMap.get(newCase.Id).Rental_Unit__c);
            }
        }

        if (!rentalUnitIds.isEmpty()) {
            List<Rental_Unit__c> rentalUnitsToUpdate = new List<Rental_Unit__c>();
            for (Rental_Unit__c rentalUnit : [
                SELECT Id, Maintenance__c, (
                    SELECT Id, Status FROM Cases__r WHERE Status != 'Closed'
                ) 
                FROM Rental_Unit__c 
                WHERE Id IN :rentalUnitIds
            ]) {
                // Initialize to false
                Boolean hasOpenCases = false;
                // Loop through related cases of rental unit
                for (Case relatedCase : rentalUnit.Cases__r) {
                    if (relatedCase.Status != 'Closed') {
                        // Update to true if case not closed
                        hasOpenCases = true;
                        break;
                    }
                }
                rentalUnit.Maintenance__c = hasOpenCases;
                rentalUnitsToUpdate.add(rentalUnit);
            }
            
            if (!rentalUnitsToUpdate.isEmpty()) {
                update rentalUnitsToUpdate;
            }
        }
    }
}