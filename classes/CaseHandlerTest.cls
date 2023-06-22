@IsTest
private with sharing class CaseHandlerTest {    
    @IsTest
    static void testUpdateMaintenance() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        Rental_Unit__c rentalUnit = TestDataFactory.createRentalUnits(1, property.Id)[0];
        List<Case> cases = TestDataFactory.createCases(201, rentalUnit.Id, 'New');

        rentalUnit = [SELECT Maintenance__c FROM Rental_Unit__c WHERE Id = :rentalUnit.Id];
        // Test Insert open cases. Open cases exist with a rental unit, Maintenance checkbox should be true
        System.assertEquals(true, rentalUnit.Maintenance__c, 'Maintenance should be checked due to open cases');

        for (Case c : cases) {
            c.Status = 'Closed';
        }
        update cases;

        rentalUnit = [SELECT Maintenance__c FROM Rental_Unit__c WHERE Id = :rentalUnit.Id];
        // Test Update to closed. Open cases do not exist, Maintenance checkbox should be false
        System.assertEquals(false, rentalUnit.Maintenance__c, 'Maintenance should be unchecked due to all closed cases');

        cases[0].Status = 'Open';        
        cases[1].Status = 'Open';
        update cases;

        rentalUnit = [SELECT Maintenance__c FROM Rental_Unit__c WHERE Id = :rentalUnit.Id];
        // Test Update to open. Mixed Open/Closed Cases exist, Maintenance checkbox should be true
        System.assertEquals(true, rentalUnit.Maintenance__c, 'Maintenance should be checked due to open cases');

        TestDataFactory.createCases(201, rentalUnit.Id, 'Closed');

        rentalUnit = [SELECT Maintenance__c FROM Rental_Unit__c WHERE Id = :rentalUnit.Id];
        // Test Insert closed. Mixed Open/Closed Cases still exist, Maintenance checkbox should be true
        System.assertEquals(true, rentalUnit.Maintenance__c, 'Maintenance should be checked due to open cases');
    }
}