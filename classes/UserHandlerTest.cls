@isTest
private class UserHandlerTest {
    @isTest
    static void testAssignPermissionSet() {
        // Create test data
        List<Contact> newContacts = new List<Contact>();
        Set<Id> newContactIds = new Set<Id>();
        for (Integer i = 0; i < 5; i++) {
            Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test' + i + '@example.com'
            );
            newContacts.add(contact);
        }
        insert newContacts;

        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'dotnetcodex@gmail.com' + System.now().millisecond() ,
            Alias = 'sfdc',
            Email='dotnetcodex@gmail.com',
            EmailEncodingKey='UTF-8',
            Firstname='Dhanik',
            Lastname='Sahni',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);

        List<User> newUsers = new List<User>();        
        Set<Id> newUserIds = new Set<Id>();
        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community User' Limit 1];
        for (Contact c : newContacts) {
            newContactIds.add(c.Id);
            c.OwnerId = portalAccountOwner1.id;
            
            User newUser = new User(
                ContactId = c.Id,
                Username = 'testuser@testuser.gmail.com',
                Email = 'testuser@testuser.gmail.com',
                FirstName = 'Test',
                LastName = 'User',
                Alias = 'testuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = portalProfile.Id,
                LanguageLocaleKey = 'en_US'   
            );
            newUsers.add(newUser);
            newUserIds.add(newUser.Id);
        }
        
        insert newUsers;

        System.debug('User Ids: ' + newUserIds);

        // Verify the results
        List<Contact> updatedContacts = [SELECT Id, Credit__c, Background_Check__c FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id IN :newUserIds)];
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :newUserIds];
        PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Experience_User' LIMIT 1];

        System.debug('Permission Set Assignments: ' + permissionSetAssignments);

        System.assertEquals(5, updatedContacts.size());
        for (Contact contact : updatedContacts) {
            System.assertEquals('Good', contact.Credit__c);
            System.assertEquals('Pass', contact.Background_Check__c);
        }

        System.assertEquals(5, permissionSetAssignments.size());
        for (PermissionSetAssignment assignment : permissionSetAssignments) {
            System.assertEquals(permissionSet.Id, assignment.PermissionSetId);
            System.assert(newUserIds.contains(assignment.AssigneeId));
        }
    }
}