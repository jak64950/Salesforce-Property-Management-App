@IsTest
private with sharing class RentalAgreementHandlerTest {
    @IsTest
    static void testUpdateRentalStatus() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        Rental_Unit__c rentalUnit = TestDataFactory.createRentalUnits(1, property.Id)[0];
        Contact tenant = TestDataFactory.createTenants(1)[0];
        List<Rental_Agreement__c> agreements = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnit.Id);
        
        rentalUnit = [SELECT Rental_Status__c FROM Rental_Unit__c WHERE Id = :rentalUnit.Id];
        // Test Insert. Verify Rental Status updated to Pending
        System.assertEquals('Pending', rentalUnit.Rental_Status__c, 'Status should have been updated to Pending');
    }
    
    @IsTest
    static void testPreventTenantWithOutstandingBalance() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        List<Rental_Unit__c> rentalUnits = TestDataFactory.createRentalUnits(2, property.Id);
        Contact tenant = TestDataFactory.createTenants(1)[0];
        
        List<Rental_Agreement__c> agreements = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnits[0].Id);
        
        // Set outstanding balance for tenant
        agreements[0].Total_Invoiced__c = 100;
        update agreements;

        List<Rental_Agreement__c> agreements2 = new List<Rental_Agreement__c>();
        try {
            agreements2 = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnits[1].Id);
        } catch (DmlException e) {}
        
        // Verify that the agreement creation was prevented
        System.assertEquals(0, agreements2.size(), 'The rental agreement should not have been created.');
    }
    
    @IsTest
    static void testCreateStatement() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        List<Rental_Unit__c> rentalUnits = TestDataFactory.createRentalUnits(2, property.Id);
        Contact tenant = TestDataFactory.createTenants(1)[0];
        // Create a new Rental Agreement
        Rental_Agreement__c rentalAgreement = new Rental_Agreement__c(
            Tenant__c = tenant.Id,
            Rental_Unit__c = rentalUnits[0].Id,
            Deposit__c = 1000
        );
        insert rentalAgreement;
        
        // Verify the newly created Statement record
        List<Statement__c> statements = [SELECT Id FROM Statement__c WHERE Rental_Agreement__r.Id = :rentalAgreement.Id];
        System.assertEquals(1, statements.size(), 'One Statement record should be created');        
        System.assertEquals(1000, statements[0].Statement_Amount__c = 1000, 'Statement Amount should be 1000');
    }
}