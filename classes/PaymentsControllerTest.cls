@IsTest
private class PaymentsControllerTest {
    @IsTest
    static void testGetContactFields() {
        // Test data setup
        Property__c property = TestDataFactory.createProperties(1)[0];
        List<Rental_Unit__c> rentalUnits = TestDataFactory.createRentalUnits(2, property.Id);
        Contact tenant = TestDataFactory.createTenants(1)[0];
        
        List<Rental_Agreement__c> agreements = TestDataFactory.createRentalAgreements(1, tenant.Id, rentalUnits[0].Id);
        tenant.FirstName = 'John';
        tenant.LastName = 'Doe';
        tenant.MailingStreet = '123 Main St';
        tenant.MailingCity = 'Anytown';
        tenant.MailingState = 'CA';
        tenant.MailingPostalCode = '12345';
        tenant.MailingCountry = 'USA';
        update tenant;

        Statement__c statement = TestDataFactory.createStatements(1, 100)[0];
        statement.Rental_Agreement__c = agreements[0].Id;
        update statement;

        // Test the getContactFields method
        Test.startTest();
        Contact result = PaymentsController.getContactFields(statement.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(tenant.Id, result.Id);
    }

    @IsTest
    static void testGetStatementFields() {
        // Test data setup
        Statement__c statement = TestDataFactory.createStatements(1, 100)[0];


        // Test the getStatementFields method
        Test.startTest();
        Decimal result = PaymentsController.getStatementFields(statement.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(100.0, result);
    }

    @IsTest
    static void testGetPaymentRecordTypes() {
        // Test the getPaymentRecordTypes method
        Test.startTest();
        List<Map<String, String>> result = PaymentsController.getPaymentRecordTypes();
        Test.stopTest();

        // Verify the result
        System.assertEquals(4, result.size());
        System.assertEquals('', result[0].get('value'));
        System.assertEquals('Select Payment Method', result[0].get('label'));
    }

    @IsTest
    static void testSavePayment() {
        // Test data setup
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Credit Card'];

        Rental_Payment__c payment = new Rental_Payment__c(
            Payment_Amount__c = 100.0,
            Billing_Name__c = 'John Doe',
            Billing_Street__c = '123 Main St',
            Billing_City__c = 'Anytown',
            Billing_State__c = 'CA',
            Billing_Country__c = 'US',
            Billing_Zip__c = '12345',
            Credit_Card_Number__c = '6011000000000012',
            Credit_Card_Expiration_Month__c = 'January',
            Credit_Card_Expiration_Year__c = '2025',
            Credit_Card_Security_Code__c = '123',
            Check_Account_Number__c = '123456789',
            Check_Routing_Number__c = '123456789',
            RecordTypeId = recordType.Id,
            Statement__c = TestDataFactory.createStatements(1, 10000)[0].Id
        );

        // Test the savePayment method    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 1));
        Boolean result = PaymentsController.savePayment(payment);
        Test.stopTest();

        // Verify the result
        System.assertEquals(true, result);
        System.assertNotEquals(null, payment.Transaction_Id__c);
        System.assertEquals('1| This transaction has been approved.', payment.Response__c);
        System.assertEquals('Paid', payment.Payment_Status__c);
        System.assertNotEquals(null, payment.Payment_Date__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 2));

        // Test the savePayment method with a declined transaction
        result = PaymentsController.savePayment(payment);

        // Verify the result
        System.assertEquals(false, result);
        System.assertEquals('2| This transaction has been declined.', payment.Response__c);
        System.assertEquals('Failed', payment.Payment_Status__c);
    }

    @IsTest
    static void testSavePayment_InvalidFieldsCC() {
        // Test data setup
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Credit Card'];

        Rental_Payment__c payment = new Rental_Payment__c(
            Payment_Amount__c = 100.0,
            Billing_Name__c = 'John Doe',
            Billing_Street__c = '123 Main St',
            Billing_City__c = 'Anytown',
            Billing_State__c = 'CA',
            Billing_Country__c = 'US',
            Billing_Zip__c = '12345',
            Credit_Card_Number__c = '',
            Credit_Card_Expiration_Month__c = '',
            Credit_Card_Expiration_Year__c = '',
            Credit_Card_Security_Code__c = '',
            RecordTypeId = recordType.Id,
            Statement__c = TestDataFactory.createStatements(1, 10000)[0].Id
        );

        // Test the savePayment method with invalid fields
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 3));
        Boolean result = PaymentsController.savePayment(payment);
        Test.stopTest();

        // Verify the result
        System.assertEquals(false, result);
    }

    @IsTest
    static void testSavePayment_InvalidFieldsCheck() {
        // Test data setup
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Check'];

        Rental_Payment__c payment = new Rental_Payment__c(
            Payment_Amount__c = 100.0,
            Billing_Name__c = 'John Doe',
            Billing_Street__c = '123 Main St',
            Billing_City__c = 'Anytown',
            Billing_State__c = 'CA',
            Billing_Country__c = 'US',
            Billing_Zip__c = '12345',
            Check_Account_Number__c = '123456789',
            Check_Routing_Number__c = '',
            RecordTypeId = recordType.Id,
            Statement__c = TestDataFactory.createStatements(1, 10000)[0].Id
        );

        // Test the savePayment method with invalid fields
        Test.startTest();
        Boolean result = PaymentsController.savePayment(payment);
        Test.stopTest();

        // Verify the result
        System.assertEquals(false, result);
    }

    @IsTest
    static void testSavePayment_InvalidFields() {
        // Test data setup
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Cash'];

        Rental_Payment__c payment = new Rental_Payment__c(
            Payment_Amount__c = null,
            Billing_Name__c = '',
            Billing_Street__c = '',
            Billing_City__c = '',
            Billing_State__c = '',
            Billing_Country__c = '',
            Billing_Zip__c = '',
            RecordTypeId = recordType.Id,
            Statement__c = TestDataFactory.createStatements(1, 10000)[0].Id
        );

        // Test the savePayment method with invalid fields
        Test.startTest();
        Boolean result = PaymentsController.savePayment(payment);
        Test.stopTest();

        // Verify the result
        System.assertEquals(false, result);
    }
}