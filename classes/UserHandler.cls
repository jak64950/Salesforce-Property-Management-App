public without sharing class UserHandler implements Queueable {
    public Map<Id, User> userMap;

    public UserHandler(Map<Id,User> userMap) {
        this.userMap = userMap;
    }

    public void execute(QueueableContext context) {
        // Get the "Experience User" permission set Id
        PermissionSet experienceUserPermissionSet = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name = 'Experience_User'
            LIMIT 1
        ];

        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();

        for (User newUser : userMap.values()) {
            if (newUser.ContactId != null) {
                PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
                permissionSetAssignment.PermissionSetId = experienceUserPermissionSet.Id;
                permissionSetAssignment.AssigneeId = newUser.Id;
                permissionSetAssignments.add(permissionSetAssignment);
            }
        }

        // Assign permission sets
        insert permissionSetAssignments;
    }
}