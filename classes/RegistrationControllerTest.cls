@IsTest
private class RegistrationControllerTest {
    @IsTest
    static void testRegisterUser() {
        // Create test data
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1][0].Id;
        Map<String, Object> registrationData = new Map<String, Object>();
        registrationData.put('firstName', 'John');
        registrationData.put('lastName', 'Doe');
        registrationData.put('email', 'test@example.com');
        registrationData.put('accountId', '001Hs00002n3wyfIAA');
        registrationData.put('birthdate', Date.valueOf('1990-01-01'));
        registrationData.put('ssn', '123456789');
        registrationData.put('dln', 'ABC123');
        registrationData.put('employment', 'Full-Time');
        registrationData.put('income', 5000.00);
        registrationData.put('phone', '1234567890');
        registrationData.put('street', '123 Main St');
        registrationData.put('city', 'Test City');
        registrationData.put('state', 'Test State');
        registrationData.put('zip', '12345');
        registrationData.put('country', 'Test Country');
        registrationData.put('password', 'te@tpass3ord');
        registrationData.put('alias', 'jdoe');
        registrationData.put('timeZoneSidKey', 'America/Los_Angeles');
        registrationData.put('localeSidKey', 'en_US');
        registrationData.put('emailEncodingKey', 'UTF-8');
        registrationData.put('profileId', profileId);
        registrationData.put('languageLocaleKey', 'en_US');

        // Call the controller method
        Test.startTest();
        RegistrationController.registerUser(registrationData);
        Test.stopTest();

        // Verify the created records
        Contact contact = [SELECT Id, FirstName, LastName, Email, Birthdate, Social_Security_Number__c,
                           Driver_License_Number__c, Employment_Status__c, Income__c, Phone,
                           MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                           Credit__c, Background_Check__c
                           FROM Contact
                           WHERE Email = 'test@example.com'];
        System.assertNotEquals(null, contact, 'Contact record should have been created');
        System.assertEquals('John', contact.FirstName);
        System.assertEquals('Doe', contact.LastName);
        // Add assertions for other fields

        User user = [SELECT Id, Username, Email, FirstName, LastName
                     FROM User
                     WHERE ContactId = :contact.Id];
        System.assertNotEquals(null, user, 'User record should have been created');
        System.assertEquals('test@example.com', user.Username);
        System.assertEquals('test@example.com', user.Email);
        System.assertEquals('John', user.FirstName);
        System.assertEquals('Doe', user.LastName);
    }
}