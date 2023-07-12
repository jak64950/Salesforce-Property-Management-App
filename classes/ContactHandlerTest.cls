@isTest
private class ContactHandlerTest {
    @isTest
    static void testUpdateContacts() {
        // Create test data
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test' + i + '@example.com'
            );
            newContacts.add(contact);
        }
        insert newContacts;

        // Verify the results
        List<Contact> updatedContacts = [SELECT Id, Credit__c, Background_Check__c FROM Contact WHERE Id IN :newContacts];
        System.assertEquals(5, updatedContacts.size());
        for (Contact contact : updatedContacts) {
            System.assertEquals('Good', contact.Credit__c);
            System.assertEquals('Pass', contact.Background_Check__c);
        }
    }
}