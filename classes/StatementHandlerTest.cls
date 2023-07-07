@isTest
private class StatementHandlerTest {
    @isTest
    static void testRollupStatementsToRentalAgreement() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        Rental_Unit__c rentalUnit = TestDataFactory.createRentalUnits(1, property.Id)[0];
        Contact tenant = TestDataFactory.createTenants(1)[0];
        Rental_Agreement__c rentalAgreement = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnit.Id)[0];
        Integer count = 4;
        List<Statement__c> statements = TestDataFactory.createStatements(count, 200);
        
        // Associate statements with rental agreements
        for (Integer i = 0; i < count; i++) {
            statements[i].Rental_Agreement__c = rentalAgreement.Id;
        }
        update statements;
        
        // Retrieve the updated rental agreement
        rentalAgreement = [SELECT Id, Total_Invoiced__c FROM Rental_Agreement__c WHERE Id = :rentalAgreement.Id];
        
        System.assertEquals(count * 200, rentalAgreement.Total_Invoiced__c); 
    }
    
    @isTest
    static void testUpdateRentalStatus() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        Rental_Unit__c rentalUnit = TestDataFactory.createRentalUnits(1, property.Id)[0];
        Contact tenant = TestDataFactory.createTenants(1)[0];
        Statement__c statement = TestDataFactory.createStatements(1, 0)[0];        
        Rental_Agreement__c rentalAgreement = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnit.Id)[0];

        statement.Rental_Agreement__c = rentalAgreement.Id;
        statement.Status__c = 'Paid';
        update statement;
        
        // Retrieve the updated rental units
        rentalUnit = [SELECT Id, Rental_Status__c FROM Rental_Unit__c WHERE Id = :rentalUnit.Id];
        
        // Assert the expected results
        System.assertEquals('Rented', rentalUnit.Rental_Status__c);
    }
}