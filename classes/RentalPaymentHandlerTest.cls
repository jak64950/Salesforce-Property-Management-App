@IsTest
private class RentalPaymentHandlerTest {
    @IsTest
    static void testRollupPaymentsToRentalAgreement() {
        // Create test data
        Property__c property = TestDataFactory.createProperties(1)[0];
        Rental_Unit__c rentalUnit = TestDataFactory.createRentalUnits(1, property.Id)[0];
        Contact tenant = TestDataFactory.createTenants(1)[0];
        Statement__c statement = TestDataFactory.createStatements(1, 100)[0];        
        Rental_Agreement__c rentalAgreement = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnit.Id)[0];

        Decimal amount = 100;
        Integer count = 2;
        // Update Statement to bypass validation rule preventing overpaying statement
        statement.Statement_Amount__c = count * amount;
        statement.Rental_Agreement__c = rentalAgreement.Id;
        update statement;
        List<Rental_Payment__c> payments = TestDataFactory.createRentalPayments(count, statement.Id, amount);

        // Test Insert Payment. Verify the rollup operation.
        Decimal expectedTotalPayments = 0;
        for (Rental_Payment__c payment : payments) {
            expectedTotalPayments += payment.Payment_Amount__c;
        }
        rentalAgreement = [SELECT Id, Total_Payments__c FROM Rental_Agreement__c WHERE Id = :rentalAgreement.Id];
        System.assertEquals(expectedTotalPayments, rentalAgreement.Total_Payments__c, 'Total Payments should be rolled up correctly');

        // Test Update Payment. Verify rollup operation.
        payments[0].Payment_Amount__c = amount + 1;
        update payments[0];
        expectedTotalPayments += 1;
        rentalAgreement = [SELECT Id, Total_Payments__c FROM Rental_Agreement__c WHERE Id = :rentalAgreement.Id];
        System.assertEquals(expectedTotalPayments, rentalAgreement.Total_Payments__c, 'Total Payments should be rolled up correctly');
 
        // Test Update Payment to Failed. Verify rollup operation ignored.
        payments[0].Payment_Status__c = 'Failed';
        payments[0].Payment_Amount__c = amount + 1;
        update payments[0];
        rentalAgreement = [SELECT Id, Total_Payments__c FROM Rental_Agreement__c WHERE Id = :rentalAgreement.Id];
        System.assertEquals(expectedTotalPayments, rentalAgreement.Total_Payments__c, 'Total Payments should remain unchanged');      
    }
}