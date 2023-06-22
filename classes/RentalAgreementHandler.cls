public with sharing class RentalAgreementHandler {
    public static void updateRentalStatus(List<Rental_Agreement__c> agreements) {
        Set<Id> rentalUnitIds = new Set<Id>();
        Map<Id, Rental_Unit__c> rentalUnitsToUpdate = new Map<Id, Rental_Unit__c>();

        for (Rental_Agreement__c agreement : agreements) {
            rentalUnitIds.add(agreement.Rental_Unit__c);
        }

        if (!rentalUnitIds.isEmpty()) {
            Map<Id, Rental_Unit__c> rentalUnitsMap = new Map<Id, Rental_Unit__c>(
                [SELECT Id, Rental_Status__c FROM Rental_Unit__c WHERE Id IN :rentalUnitIds]
            );
            
            // Update rental unit status to pending if related to rental agreement
            for (Rental_Agreement__c agreement : agreements) {
                if (rentalUnitsMap.containsKey(agreement.Rental_Unit__c)) {
                    Rental_Unit__c rentalUnit = rentalUnitsMap.get(agreement.Rental_Unit__c);
                    rentalUnit.Rental_Status__c = 'Pending';
                    rentalUnitsToUpdate.put(rentalUnit.Id, rentalUnit);
                }
            }

            if (!rentalUnitsToUpdate.isEmpty()) {
                update rentalUnitsToUpdate.values();
            }
        }
    }

    public static void preventTenantWithOutstandingBalance(List<Rental_Agreement__c> agreements) {    
        // Collect the Tenant Ids from the new and updated Rental Agreements
        Set<Id> tenantIds = new Set<Id>();
    
        for (Rental_Agreement__c agreement : agreements) {
            tenantIds.add(agreement.Tenant__c);
        }
        
        // Query related Rental Agreements with outstanding balance
        List<Rental_Agreement__c> relatedAgreements = [SELECT Id, Tenant__c, Outstanding_Balance__c FROM Rental_Agreement__c WHERE Tenant__c IN :tenantIds AND Outstanding_Balance__c > 0];
        
        Map<Id, Decimal> tenantBalances = new Map<Id, Decimal>();
        
        // Store the outstanding balances for each Contact
        for (Rental_Agreement__c agreement : relatedAgreements) {
            if (!tenantBalances.containsKey(agreement.Tenant__c)) {
                tenantBalances.put(agreement.Tenant__c, 0);
            }
            tenantBalances.put(agreement.Tenant__c, tenantBalances.get(agreement.Tenant__c) + agreement.Outstanding_Balance__c);
        }
        
        // Check if any Tenant has an outstanding balance
        for (Rental_Agreement__c agreement : agreements) {
            if (tenantBalances.containsKey(agreement.Tenant__c) && tenantBalances.get(agreement.Tenant__c) > 0) {
                agreement.addError('Cannot create a new Rental Agreement for a Tenant with an outstanding balance on other Rental Agreements.');
            }
        }  
    }

    public static void createStatement(List<Rental_Agreement__c> rentalAgreements) {
        List<Statement__c> statementsToCreate = new List<Statement__c>();
        
        for (Rental_Agreement__c rentalAgreement : rentalAgreements) {
            // Create a new Statement record and populate the necessary fields
            Statement__c statement = new Statement__c(
                Rental_Agreement__c = rentalAgreement.Id,
                Statement_Amount__c = rentalAgreement.Total_Deposit__c
            );
            
            statementsToCreate.add(statement);
        }
        
        insert statementsToCreate;
    }
}