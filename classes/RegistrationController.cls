public without sharing class RegistrationController {
    @AuraEnabled(cacheable=false)
    public static void registerUser(Map<String, Object> registrationData) {
        // Extract registration data
        String firstName = (String) registrationData.get('firstName');
        String lastName = (String) registrationData.get('lastName');
        String email = (String) registrationData.get('email');
        Date birthdate = (Date) registrationData.get('birthdate');
        String ssn = (String) registrationData.get('ssn');
        String dln = (String) registrationData.get('dln');
        String employment = (String) registrationData.get('employment');
        Decimal income = (Decimal) registrationData.get('income');
        String phone = (String) registrationData.get('phone');
        String street = (String) registrationData.get('street');
        String city = (String) registrationData.get('city');
        String state = (String) registrationData.get('state');
        String zip = (String) registrationData.get('zip');
        String country = (String) registrationData.get('country');
        String password = (String) registrationData.get('password');
        
        // Get the Customer Community User Profile Id
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1].Id;
        
        // Create the Contact
        Id accountId = [SELECT Id, Name FROM Account WHERE Name = 'The Slums' LIMIT 1].Id;
        Contact contact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            AccountId = accountId,
            Birthdate = birthdate,
            Social_Security_Number__c = ssn,
            Driver_License_Number__c = dln,
            Employment_Status__c = employment,
            Income__c = income,
            Phone = phone,
            MailingStreet = street,
            MailingCity = city,
            MailingState = state,
            MailingPostalCode = zip,
            MailingCountry = country,
            Credit__c = 'Excellent',
            Background_Check__c = 'Pass'
        );
        insert contact;
        
        // Create the User
        String alias = '';
        if (email.split('@')[0].length() > 8) {
            alias = email.split('@')[0].substring(0,8);
        } else {
            alias = email.split('@')[0].substring(0,email.split('@')[0].length());
        }

        User user = new User(
            ContactId = contact.Id,
            Username = email,
            Email = email,
            FirstName = firstName,
            LastName = lastName,
            Alias = alias,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profileId,
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        
        System.setPassword(user.Id, password);
    }
}