public without sharing class ContactHandler {
    public static void assignPermissionSet(List<Contact> newContacts) {
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        
        // Get the "Experience User" permission set Id
        PermissionSet experienceUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Experience User'
            LIMIT 1
        ];
        
        for (Contact newContact : newContacts) {
            // Update fields
            newContact.Credit__c = 'Good';
            newContact.Background_Check__c = 'Pass';
            
            // Assign the "Experience User" permission set
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
            permissionSetAssignment.PermissionSetId = experienceUserPermissionSet.Id;
            permissionSetAssignment.AssigneeId = newContact.Id;
            permissionSetAssignments.add(permissionSetAssignment);
        }
        
        // Update contacts
        update newContacts;
        
        // Assign permission sets
        insert permissionSetAssignments;
    }
}