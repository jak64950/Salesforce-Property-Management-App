public without sharing class RentalAgreementController {
    @AuraEnabled(cacheable=true)
    public static List<Rental_Unit__c> getProperties(String street, String city, String state, String zip, Integer bedrooms, Integer bathrooms, Integer squareFootage, Integer rent, Boolean pets) {
        // Create a dynamic SOQL query to filter records based on the input criteria
        String queryProperty = 'Property__c IN :propIds';
        String queryUnit = 'SELECT Id, Rent__c, Pet_Friendly__c, Name, Property__c, Property__r.Name, Property__r.Property_Street__c, Property__r.Property_City__c, Property__r.Property_State__c, Property__r.Property_Zip__c, Bedrooms__c, Bathrooms__c, Square_Footage__c FROM Rental_Unit__c WHERE ';

        List<String> filters = new List<String>();
        Set<Id> propIds = new Set<Id>();
        if (!String.isBlank(street)) {
            List<Property__c> propertiesByStreet = [SELECT Id, Property_Street__c FROM Property__c WHERE Property_Street__c LIKE :'%' + street + '%'];
            for (Property__c property : propertiesByStreet) {
                propIds.add(property.Id);
            }
        }
        if (!String.isBlank(city)) {
            List<Property__c> propertiesByCity = [SELECT Id, Property_City__c FROM Property__c WHERE Property_City__c LIKE :'%' + city + '%'];
            for (Property__c property : propertiesByCity) {
                propIds.add(property.Id);
            }
        }
        if (!String.isBlank(state)) {
            List<Property__c> propertiesByState = [SELECT Id, Property_State__c FROM Property__c WHERE Property_State__c LIKE :'%' + state + '%'];
            for (Property__c property : propertiesByState) {
                propIds.add(property.Id);
            }
        }        
        if (!String.isBlank(zip)) {
            List<Property__c> propertiesByZip = [SELECT Id, Property_Zip__c FROM Property__c WHERE Property_Zip__c LIKE :'%' + zip + '%'];
            for (Property__c property : propertiesByZip) {
                propIds.add(property.Id);
            }
        }
        if (propIds.isEmpty()) {
            List<Property__c> allProperties = [SELECT Id FROM Property__c];
            for (Property__c property : allProperties) {
                propIds.add(property.Id);
            }
        }
        if (bedrooms != null) {
            filters.add('Bedrooms__c >= ' + bedrooms);
        }
        if (bathrooms != null) {
            filters.add('Bathrooms__c >= ' + bathrooms);
        }
        if (squareFootage != null) {
            filters.add('Square_Footage__c >= ' + squareFootage);
        }
        if (rent != null) {
            filters.add('Rent__c <= ' + rent);
        }
        
        if (filters.isEmpty()) {
            // If no filters applied, return all rental units
            queryUnit += queryProperty;
        } else {
            queryUnit += queryProperty + ' AND ' + String.join(filters, ' AND ') + ' AND Rental_Status__c = \'Available\'';
        }
        return Database.query(queryUnit);
    }

    @AuraEnabled(cacheable=true)
    public static Rental_Unit__c saveRentalAgreement(String recordId) {
        Rental_Unit__c rentalUnit = [SELECT Id, Rent__c, Pet_Friendly__c, Name, Property__c, Property__r.Name, Property__r.Property_Street__c, Property__r.Property_City__c, Property__r.Property_State__c, Property__r.Property_Zip__c, Bedrooms__c, Bathrooms__c, Square_Footage__c FROM Rental_Unit__c WHERE Id = :recordId LIMIT 1];

        return rentalUnit;    
    }

    @AuraEnabled(cacheable=true)
    public static Id getContactId() {
        Id userId = UserInfo.getUserId();
        User currentUser = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1][0];
        Id contactId = currentUser.ContactId;

        return contactId;    
    }

    @AuraEnabled(cacheable=false)
    public static Id createRentalAgreement(String recordId) {
        // Create a new rental agreement
        Rental_Unit__c rentalUnit = [SELECT Id, Name, Rent__c FROM Rental_Unit__c WHERE Id = :recordId LIMIT 1][0];
        Rental_Agreement__c rentalAgreement = new Rental_Agreement__c();
        rentalAgreement.Tenant__c = getContactId();
        rentalAgreement.Rental_Unit__c = rentalUnit.Id;
        rentalAgreement.Rental_Amount__c = rentalUnit.Rent__c;
        rentalAgreement.Deposit__c = rentalUnit.Rent__c * 2;
        rentalAgreement.Lease_Start_Date__c = Date.today();
        rentalAgreement.Lease_End_Date__c = Date.today().addMonths(12);
        insert rentalAgreement;

        if (rentalAgreement.Id != null) {
            return rentalAgreement.Id;
        } else {
            return null;
        }
    }
}