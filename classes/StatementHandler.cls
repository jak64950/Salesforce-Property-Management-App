public without sharing class StatementHandler {
    public static void updateRentalStatus(List<Statement__c> statements) {
        Set<Id> rentalUnitIds = new Set<Id>();
        
        // Query Rental_Agreement__r and Rental_Unit__c fields along with the Statement records
        statements = [SELECT Id, Status__c, Rental_Agreement__r.Rental_Unit__c
                        FROM Statement__c
                        WHERE Id IN :statements
                        AND Status__c = 'Paid'];
        for (Statement__c statement : statements) {
            // Check if the Status field is set to "Paid"
            if (statement.Rental_Agreement__c != null) {
                rentalUnitIds.add(statement.Rental_Agreement__r.Rental_Unit__c);
            }
        }

        if (!rentalUnitIds.isEmpty()) {
            List<Rental_Unit__c> rentalUnitsToUpdate = [
                SELECT Id, Rental_Status__c
                FROM Rental_Unit__c
                WHERE Id IN :rentalUnitIds
                    AND Rental_Status__c != 'Rented'
            ];

            if (!rentalUnitsToUpdate.isEmpty()) {
                for (Rental_Unit__c rentalUnit : rentalUnitsToUpdate) {
                    // Update the Rental_Status__c field to "Rented"
                    rentalUnit.Rental_Status__c = 'Rented';
                }
            }

            // Update the Rental_Unit__c records
            update rentalUnitsToUpdate;
        }
    }

    public static void rollupStatementsToRentalAgreement(List<Statement__c> statementList) {
        Set<Id> rentalAgreementIds = new Set<Id>();
        // Add related rental agreements to set
        for (Statement__c statement : statementList) {
            if (statement.Rental_Agreement__c != null) {
                rentalAgreementIds.add(statement.Rental_Agreement__c); }
        }        
        
        // Query Related rental agreements
        List<Rental_Agreement__c> rentalAgreements = [
            SELECT Id, Total_Invoiced__c 
            FROM Rental_Agreement__c 
            WHERE Id IN :rentalAgreementIds
        ];

        // Query all Related statements to rental agreement (not just triggered)
        List<Statement__c> relatedStatements = [
            SELECT Id, Statement_Amount__c, Rental_Agreement__c
            FROM Statement__c
            WHERE Rental_Agreement__c IN :rentalAgreements
        ];

        List<Rental_Agreement__c> agreementUpdates = new List<Rental_Agreement__c>();
        // Calculate running tally of invoice amounts from all related statements
        for (Rental_Agreement__c rentalAgreement : rentalAgreements) {
            Decimal totalInvoiced = 0;
            for (Statement__c statement : relatedStatements) {        
                if (statement.Rental_Agreement__c == rentalAgreement.Id) {
                    totalInvoiced += statement.Statement_Amount__c;
                }
            }
            rentalAgreement.Total_Invoiced__c = totalInvoiced;
            agreementUpdates.add(rentalAgreement);
        }
        
        if (!agreementUpdates.isEmpty()) {
            update agreementUpdates;
        }
    }   
}