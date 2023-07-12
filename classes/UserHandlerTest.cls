@isTest
private class UserHandlerTest {
    @isTest
    static void testUserHandler() {
        List<User> newUsers = TestDataFactory.createUsers(5);

        // Verify the results
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :newUsers];
        PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Experience_User' LIMIT 1];

        List<Id> userIds = new List<Id>();
        for (User user : newUsers) {
            userIds.add(user.Id);
        }

        System.assertEquals(10, permissionSetAssignments.size());
        for (PermissionSetAssignment assignment : permissionSetAssignments) {
            //System.assertEquals(permissionSet.Id, assignment.PermissionSetId);
            System.assert(userIds.contains(assignment.AssigneeId));
        }
    }
}