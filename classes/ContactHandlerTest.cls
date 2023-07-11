@isTest
private class ContactHandlerTest {
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

        List<User> newUsers = new List<User>();
        for (Contact c : newContacts) {
            newContactIds.add(c.Id);
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
                ProfileId = '00eHs000000xQMSIA2',
                LanguageLocaleKey = 'en_US'    
            );
            newUsers.add(newUser);
        }
        
        insert newUsers;

        Set<Id> userIds = new Set<Id>();
        for (User user : newUsers) {
            userIds.add(user.Id);
        }

        System.debug('Ids: ' + newContactIds);

        // Verify the results
        List<Contact> updatedContacts = [SELECT Id, Credit__c, Background_Check__c FROM Contact WHERE Id IN :newContactIds];
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :userIds];
        PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Experience_User' LIMIT 1];

        System.debug('Permission Set Assignments: ' + permissionSetAssignments);

        System.assertEquals(5, updatedContacts.size());
        for (Contact contact : updatedContacts) {
            System.assertEquals('Good', contact.Credit__c);
            System.assertEquals('Pass', contact.Background_Check__c);
        }

        //System.assertEquals(5, permissionSetAssignments.size());
        for (PermissionSetAssignment assignment : permissionSetAssignments) {
            System.assertEquals(permissionSet.Id, assignment.PermissionSetId);
            System.assert(userIds.contains(assignment.AssigneeId));
        }
    }
}