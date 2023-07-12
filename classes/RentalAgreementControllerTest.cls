@isTest
private class RentalAgreementControllerTest {
    @isTest
    static void testGetProperties() {
        // Create test data
        Property__c property = new Property__c(
            Property_Street__c = '123 Test Street',
            Property_City__c = 'Test City',
            Property_State__c = 'OH',
            Property_Zip__c = '12345'
        );
        insert property;

        Rental_Unit__c rentalUnit = new Rental_Unit__c(
            Rent__c = 2000,
            Pet_Friendly__c = false,
            Property__c = property.Id,
            Bedrooms__c = 2,
            Bathrooms__c = 2,
            Square_Footage__c = 1000
        );
        insert rentalUnit;

        Test.startTest();
        List<Rental_Unit__c> result = RentalAgreementController.getProperties(null, 'Test City', null, null, 2, null, null, null);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, result.size());
    }

    @isTest
    static void testSaveRentalAgreement() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0]; 
        Rental_Unit__c rentalUnit = new Rental_Unit__c(
            Rent__c = 2000,
            Pet_Friendly__c = false,
            Property__c = property.Id
        );
        insert rentalUnit;

        Test.startTest();
        Rental_Unit__c result = RentalAgreementController.saveRentalAgreement(rentalUnit.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(rentalUnit.Id, result.Id);
    }

    @isTest
    static void testGetContactId() {
        // Create test data
        User newUser = TestDataFactory.createUsers(1)[0];

        Test.startTest();
        Id result = RentalAgreementController.getContactId();
        Test.stopTest();

        // Verify the result
        System.assertEquals(newUser.ContactId, result);
    }

    @isTest
    static void testCreateRentalAgreement() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        Rental_Unit__c rentalUnit = new Rental_Unit__c(
            Rent__c = 2000,
            Pet_Friendly__c = false,
            Property__c = property.Id
        );
        insert rentalUnit;

        Test.startTest();
        Id result = RentalAgreementController.createRentalAgreement(rentalUnit.Id);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result);
    }
}