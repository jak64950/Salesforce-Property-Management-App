@IsTest
public with sharing class TestDataFactoryTest {
    @IsTest
    public static void testCreateProperties() {
        List<Property__c> properties = TestDataFactory.createProperties(3);
        System.assertEquals(3, properties.size());
    }

    @IsTest
    public static void testCreateRentalUnits() {
        // Create a property first
        Property__c property = new Property__c(Name = 'Test Property');
        insert property;

        List<Rental_Unit__c> rentalUnits = TestDataFactory.createRentalUnits(2, property.Id);
        System.assertEquals(2, rentalUnits.size());
    }

    @IsTest
    public static void testCreateTenants() {
        List<Contact> tenants = TestDataFactory.createTenants(5);
        System.assertEquals(5, tenants.size());
    }

    @IsTest
    public static void testCreateRentalAgreements() {
        // Create a tenant and rental unit first
        Contact tenant = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Background_Check__c = 'Pass',
            Credit__c = 'Good'
        );
        insert tenant;

        // Create a property first
        Property__c property = new Property__c(Name = 'Test Property');
        insert property;

        Rental_Unit__c rentalUnit = new Rental_Unit__c(
            Property__c = property.Id,
            Rental_Status__c = 'Available'
        );
        insert rentalUnit;

        List<Rental_Agreement__c> rentalAgreements = TestDataFactory.createRentalAgreements(3, tenant.Id, rentalUnit.Id);
        System.assertEquals(3, rentalAgreements.size());
    }

    @IsTest
    public static void testCreateStatements() {
        List<Statement__c> statements = TestDataFactory.createStatements(4, 100);
        System.assertEquals(4, statements.size());
    }

    @IsTest
    public static void testCreateRentalPayments() {
        // Create a statement first
        Statement__c statement = new Statement__c(Statement_Amount__c = 1000);
        insert statement;

        List<Rental_Payment__c> rentalPayments = TestDataFactory.createRentalPayments(2, statement.Id, 100.00);
        System.assertEquals(2, rentalPayments.size());
    }

    @IsTest
    public static void testCreateCases() {
        // Create a property first
        Property__c property = new Property__c(Name = 'Test Property');
        insert property;

        // Create a rental unit first
        Rental_Unit__c rentalUnit = new Rental_Unit__c(
            Property__c = property.Id,
            Rental_Status__c = 'Available'
        );
        insert rentalUnit;

        List<Case> cases = TestDataFactory.createCases(3, rentalUnit.Id, 'Open');
        System.assertEquals(3, cases.size());
    }
}
