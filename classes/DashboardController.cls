public with sharing class DashboardController {
    public Contact contact { get; private set; }
    public Map<Id, List<Rental_Agreement__c>> groupMap {get; private set; }
    public List<Rental_Agreement__c> rentalAgreements { get; private set; }
    public List<Case> openCases { get; private set; }
    
    public DashboardController(ApexPages.StandardController controller) {
        Id userId = UserInfo.getUserId();
        User currentUser = [
            SELECT Id, ContactId, FirstName, LastName, Email, Phone, Street, City, State, Country, PostalCode 
            FROM User 
            WHERE Id = :userId
        ];
        Id contactId = currentUser.ContactId;
        if (contactId != null) {
            contact = [
                SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
                FROM Contact 
                WHERE Id = :contactId
            ];
        } else {
            contact = new Contact(
                FirstName = currentUser.FirstName,
                LastName = currentUser.LastName,
                Email = currentUser.Email,
                Phone = currentUser.Phone,
                MailingStreet = currentUser.Street,
                MailingCity = currentUser.City,
                MailingState = currentUser.State,
                MailingPostalCode = currentUser.PostalCode,
                MailingCountry = currentUser.Country
            );
        }
        populateRentalAgreements();
        populateOpenCases();
        groupSolution();
    }
    
    private void populateRentalAgreements() {
        rentalAgreements = [
            SELECT Rental_Unit__r.Property__r.Name, Rental_Unit__r.Name, Lease_Start_Date__c, Lease_End_Date__c, Outstanding_Balance__c
            FROM Rental_Agreement__c
            WHERE Tenant__c = :contact.Id
            ORDER BY Rental_Unit__r.Property__r.Name, Rental_Unit__r.Name
        ];
    }
    
    private void populateOpenCases() {
        openCases = [
            SELECT Subject, Rental_Unit__c, Status, Priority
            FROM Case
            WHERE ContactId = :contact.Id AND Status != 'Closed'
        ];
    }
    
    private void groupSolution() {
        groupMap = new Map<Id, List<Rental_Agreement__c>>();
    
        for (Rental_Agreement__c rentalAgreement : rentalAgreements) {
            if (rentalAgreement.Lease_End_Date__c >= Date.today()) {
                Rental_Unit__c rentalUnit = rentalAgreement.Rental_Unit__r;
                Property__c property = rentalUnit.Property__r;
    
                if (!groupMap.containsKey(property.Id)) {
                    groupMap.put(property.Id, new List<Rental_Agreement__c>());
                }
    
                groupMap.get(property.Id).add(rentalAgreement);
            }
        }
    }
}