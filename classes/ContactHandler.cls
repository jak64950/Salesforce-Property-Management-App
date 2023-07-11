public without sharing class ContactHandler {
    public static void updateContacts(List<Contact> newContacts) {

        Set<Id> contactIds = new Set<Id>();
        for (Contact newContact : newContacts) {
            contactIds.add(newContact.Id);
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Credit__c, Background_Check__c
            FROM Contact
            WHERE Id IN :contactIds
        ]);
        
        for (Contact newContact : newContacts) {
            // Update fields
            Contact contactToUpdate = contactMap.get(newContact.Id);
            contactToUpdate.Credit__c = 'Good';
            contactToUpdate.Background_Check__c = 'Pass';
        }
        
        // Update contacts
        update contactMap.values();
    }
}