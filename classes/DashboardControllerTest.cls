@isTest
private class DashboardControllerTest {
    @isTest
    static void testDashboardController() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@test.com',
            Phone = '1234567890',
            MailingStreet = '123 Test Street',
            MailingCity = 'Test City',
            MailingState = 'Test State',
            MailingCountry = 'Test Country',
            MailingPostalCode = '12345'
        );
        insert testContact;

        User testUser = TestDataFactory.createUsers(1)[0];

        Rental_Unit__c rentalUnit = new Rental_Unit__c(
            Property__r = new Property__c(Name = 'Test Property')
        );
        insert rentalUnit;

        Rental_Agreement__c rentalAgreement = new Rental_Agreement__c(
            Tenant__c = testContact.Id,
            Rental_Unit__c = rentalUnit.Id,
            Lease_Start_Date__c = Date.today(),
            Lease_End_Date__c = Date.today().addMonths(12)
        );
        insert rentalAgreement;

        Case testCase = new Case(
            Subject = 'Test Case',
            Rental_Unit__c = rentalUnit.Id,
            Status = 'Open',
            Priority = 'High',
            ContactId = testContact.Id
        );
        insert testCase;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testUser);
        DashboardController controller = new DashboardController(stdController);
        Test.stopTest();

        // Verify the results
        System.assertEquals(testContact.Id, controller.contact.Id);
        System.assertEquals(testContact.FirstName, controller.contact.FirstName);
        System.assertEquals(testContact.LastName, controller.contact.LastName);
        System.assertEquals(testContact.Email, controller.contact.Email);
        System.assertEquals(testContact.Phone, controller.contact.Phone);
        System.assertEquals(testContact.MailingStreet, controller.contact.MailingStreet);
        System.assertEquals(testContact.MailingCity, controller.contact.MailingCity);
        System.assertEquals(testContact.MailingState, controller.contact.MailingState);
        System.assertEquals(testContact.MailingCountry, controller.contact.MailingCountry);
        System.assertEquals(testContact.MailingPostalCode, controller.contact.MailingPostalCode);

        System.assertEquals(1, controller.rentalAgreements.size());
        Rental_Agreement__c retrievedRentalAgreement = controller.rentalAgreements[0];
        System.assertEquals(rentalUnit.Property__r.Name, retrievedRentalAgreement.Rental_Unit__r.Property__r.Name);
        System.assertEquals(rentalUnit.Name, retrievedRentalAgreement.Rental_Unit__r.Name);
        System.assertEquals(rentalAgreement.Lease_Start_Date__c, retrievedRentalAgreement.Lease_Start_Date__c);
        System.assertEquals(rentalAgreement.Lease_End_Date__c, retrievedRentalAgreement.Lease_End_Date__c);

        System.assertEquals(1, controller.openCases.size());
        Case retrievedCase = controller.openCases[0];
        System.assertEquals(testCase.Subject, retrievedCase.Subject);
        System.assertEquals(testCase.Rental_Unit__c, retrievedCase.Rental_Unit__c);
        System.assertEquals(testCase.Status, retrievedCase.Status);
        System.assertEquals(testCase.Priority, retrievedCase.Priority);

        System.assertEquals(1, controller.groupMap.size());
        List<Rental_Agreement__c> rentalAgreements = controller.groupMap.get(rentalUnit.Property__r.Id);
        System.assertEquals(1, rentalAgreements.size());
        Rental_Agreement__c retrievedGroupedRentalAgreement = rentalAgreements[0];
        System.assertEquals(rentalUnit.Property__r.Name, retrievedGroupedRentalAgreement.Rental_Unit__r.Property__r.Name);
        System.assertEquals(rentalUnit.Name, retrievedGroupedRentalAgreement.Rental_Unit__r.Name);
        System.assertEquals(rentalAgreement.Lease_Start_Date__c, retrievedGroupedRentalAgreement.Lease_Start_Date__c);
        System.assertEquals(rentalAgreement.Lease_End_Date__c, retrievedGroupedRentalAgreement.Lease_End_Date__c);
    }
}