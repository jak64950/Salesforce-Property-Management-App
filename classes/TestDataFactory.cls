public without sharing class TestDataFactory {
    public static List<Property__c> createProperties(Integer count) {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < count; i++) {
            properties.add(new Property__c(
                Name = 'Property ' + i
            ));
        }
        insert properties;
        return properties;
    }

    public static List<Rental_Unit__c> createRentalUnits(Integer count, Id propertyId) {
        List<Rental_Unit__c> rentalUnits = new List<Rental_Unit__c>();
        for (Integer i = 0; i < count; i++) {
            rentalUnits.add(new Rental_Unit__c(
                Property__c = propertyId,
                Rental_Status__c = 'Available' 
            ));
        }
        insert rentalUnits;
        return rentalUnits;
    }

    public static List<Contact> createTenants(Integer count) {
        List<Contact> tenants = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            tenants.add(new Contact(
                FirstName = 'Tenant',
                LastName = String.valueOf(i),
                Background_Check__c = 'Pass',
                Credit__c = 'Good'
            ));
        }
        insert tenants;
        return tenants;
    }

    public static List<Rental_Agreement__c> createRentalAgreements(Integer count, Id tenant, Id rental) {
        List<Rental_Agreement__c> rentalAgreements = new List<Rental_Agreement__c>();
        for (Integer i = 0; i < count; i++) {
            rentalAgreements.add(new Rental_Agreement__c(
                Tenant__c = tenant,
                Rental_Unit__c = rental
            ));
        }
        insert rentalAgreements;
        return rentalAgreements;
    }
    
    public static List<Statement__c> createStatements(Integer count, Integer amount) {
        List<Statement__c> statements = new List<Statement__c>();
        for (Integer i = 0; i < count; i++) {
            statements.add(new Statement__c(
                Statement_Amount__c = amount
            ));
        }
        insert statements;
        return statements;
    }

    public static List<Rental_Payment__c> createRentalPayments(Integer count, Id statement, Decimal amount) {
        List<Rental_Payment__c> rentalPayments = new List<Rental_Payment__c>();
        for (Integer i = 0; i < count; i++) {
            rentalPayments.add(new Rental_Payment__c(
                Payment_Amount__c = amount,
                Statement__c = statement
            ));
        }
        insert rentalPayments;
        return rentalPayments;
    }
    
    public static List<Case> createCases(Integer count, Id rentalUnit, String stat) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < count; i++) {
            cases.add(new Case(
                Status = stat,
                Origin = 'Phone',
                Rental_Unit__c = rentalUnit
            ));
        }
        insert cases;
        return cases;
    }
    
    public static List<User> createUsers(Integer count) {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);

        User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];
        List<User> newUsers = new List<User>();
        List<Contact> newContacts = new List<Contact>();

        System.runAs ( portalAccountOwner1 ) {
        //Create account
        Account portalAccount1 = new Account(
        Name = 'TestAccount',
        OwnerId = portalAccountOwner1.Id
        );
        Database.insert(portalAccount1);

        //Create contacts
        for (Integer i = 0; i < count; i++){
            Contact contact = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty ' + i,
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + i + 'test@test.com'
            );
            newContacts.add(contact);
        }
        Database.insert(newContacts);

        Profile profile = [SELECT Name, Id FROM Profile WHERE Name = 'Customer Community User'];
        for (Integer i = 0; i < count; i++) {
            User newUser = new User(
                ContactId = newContacts[i].Id,
                Username = 'testuser' + i + '@testuser.gmail.com',
                Email = 'testuser@testuser.gmail.com',
                FirstName = 'Test',
                LastName = 'User' + i,
                Alias = 'tstusr' + i,
                CommunityNickname = 'test12345' + i,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US'  
            );
            newUsers.add(newUser);
        }
        insert newUsers;
    }
        return newUsers;
    }
}
