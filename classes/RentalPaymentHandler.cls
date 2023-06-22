public with sharing class RentalPaymentHandler {
    public static void rollupPaymentsToRentalAgreement(Map<Id, Rental_Payment__c> paymentMap) {
        Set<Id> rentalAgreementSet = new Set<Id>();
        // Query trigger payments
        Map<Id, Rental_Payment__c> paymentMapById = new Map<Id, Rental_Payment__c>([
            SELECT Id, Statement__c, Statement__r.Rental_Agreement__c, Payment_Amount__c 
            FROM Rental_Payment__c 
            WHERE Id IN :paymentMap.keySet()
        ]);
        
        // Add related rental agreements to set
        for (Rental_Payment__c payment : paymentMapById.values()) {
            rentalAgreementSet.add(payment.Statement__r.Rental_Agreement__c);
        }
        
        // Query Related rental agreements
        List<Rental_Agreement__c> rentalAgreements = [
            SELECT Id, Total_Payments__c 
            FROM Rental_Agreement__c 
            WHERE Id IN :rentalAgreementSet
        ];
        
        List<Rental_Agreement__c> rentalUpdates = new List<Rental_Agreement__c>();
        // Query all Related payments to rental agreement (not just triggered)
        List<Rental_Payment__c> relatedPayments = [
            SELECT Id, Payment_Amount__c, Statement__r.Rental_Agreement__c
            FROM Rental_Payment__c
            WHERE Statement__r.Rental_Agreement__c IN :rentalAgreements
        ];
        // Calculate running tally of payment amounts from all related payments
        for (Rental_Agreement__c rentalAgreement : rentalAgreements) {
            Decimal totalPaid = 0;
            for (Rental_Payment__c payment : relatedPayments) {        
                if (payment.Statement__r.Rental_Agreement__c == rentalAgreement.Id) {
                    totalPaid += payment.Payment_Amount__c;
                }
            }
            rentalAgreement.Total_Payments__c = totalPaid;
            rentalUpdates.add(rentalAgreement);
        }
        
        if (!rentalUpdates.isEmpty()) {
            update rentalUpdates;
        }
    }
}