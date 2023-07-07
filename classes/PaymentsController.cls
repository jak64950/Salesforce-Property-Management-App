public without sharing class PaymentsController {
    @AuraEnabled(cacheable=true)
    public static Contact getContactFields(Id statementId) {
        Statement__c statement = [SELECT Id, Rental_Agreement__r.Tenant__c FROM Statement__c WHERE Id = :statementId];
        Contact contact = [
            SELECT FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM Contact 
            WHERE Id = :statement.Rental_Agreement__r.Tenant__c
        ];
        return contact;
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getStatementFields(Id statementId) {
        Statement__c statement = [SELECT Id, Balance__c FROM Statement__c WHERE Id = :statementId];
        Decimal paymentAmount = statement.Balance__c;

        return paymentAmount;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPaymentRecordTypes() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        // Check if the user is a system admin
        Boolean isSystemAdmin = isCurrentUserSystemAdmin();
        
        if (isSystemAdmin) {
            // User is a system admin, include all payment record types
            for (RecordType recordType : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rental_Payment__c']) {
                options.add(new Map<String, String>{ 'value' => recordType.Id, 'label' => recordType.Name });
            }
        } else {
            // User is not a system admin, include only the "Credit Card" option
            for (RecordType recordType : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rental_Payment__c' AND Name = 'Credit Card']) {
                options.add(new Map<String, String>{ 'value' => recordType.Id, 'label' => recordType.Name });
            }
        }
        return options;
    }

    private static Boolean isCurrentUserSystemAdmin() {
        // Retrieve the current user's profile or permission set
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        PermissionSetAssignment userPermissionSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() LIMIT 1];
        // Check if the profile or permission set indicates the user is a system admin
        if (userProfile != null && userProfile.Name == 'System Administrator') {
            return true;
        } else if (userPermissionSet != null && userPermissionSet.PermissionSet.Name == 'System Administrator') {
            return true;
        }
        
        return false;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean savePayment(Rental_Payment__c payment) {
        //try {
            if (validateFields(payment)) {
                if (payment.RecordTypeId == [SELECT Id, Name FROM RecordType WHERE Name = 'Credit Card'][0].Id) {
                    // Process credit card payments
                    API_ADN.Req_Wrapper req = new API_ADN.Req_Wrapper();
                    req.amt = String.valueOf(payment.Payment_Amount__c);
                    req.firstname = payment.Billing_Name__c.contains(' ') ? payment.Billing_Name__c.substringBefore(' ') : payment.Billing_Name__c;
                    req.lastname = payment.Billing_Name__c.contains(' ') ? payment.Billing_Name__c.substringAfter(' ') : payment.Billing_Name__c;
                    req.billstreet = payment.Billing_Street__c;
                    req.billcity = payment.Billing_City__c;
                    req.billstate = payment.Billing_State__c;
                    req.billzip = payment.Billing_Zip__c;
                    req.ccnum = payment.Credit_Card_Number__c;
                    req.ccexp = payment.Credit_Card_Expiration_Year__c + '-' + monthMap.get(payment.Credit_Card_Expiration_Month__c);
                    req.ccsec = payment.Credit_Card_Security_Code__c;
                    req.ordername = 'Payment of ' + [SELECT Id, Name FROM Statement__c WHERE Id = :payment.Statement__c].Name;
                    
                    API_ADN.Resp_Wrapper res = API_ADN.authorizeCharge(req);

                    payment.Transaction_Id__c = res.transid;
                    payment.Authorization_Code__c = res.authcode;
                    Map<String, String> respreasonmap = new Map<String, String>{
                        '1' => 'This transaction has been approved.',
                        '2' => 'This transaction has been declined.',
                        '3' => 'There has been an error processing this transaction.',
                        '4' => 'This transaction has been held for review.'
                    };

                    payment.Response__c = res.respcode + '| ' + respreasonmap.get(res.respcode);

                    if (res.respcode != '1') {
                        payment.Payment_Status__c = 'Failed';

                        upsert payment;
                        return false;
                    }
                }
                
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Date__c = System.now();
                upsert payment;
                return true;

            } else {
                return false;
            }
       // } catch (Exception e) {
       //     return false;
       // }
    }

    private static Boolean validateFields(Rental_Payment__c payment) {
        // Check if all required fields are filled out
        if (payment.Payment_Amount__c == null ||
            String.isBlank(payment.Billing_Name__c) ||
            String.isBlank(payment.Billing_Street__c) ||
            String.isBlank(payment.Billing_City__c) ||
            String.isBlank(payment.Billing_State__c) ||
            String.isBlank(payment.Billing_Country__c) ||
            String.isBlank(payment.Billing_Zip__c)) {
            return false;
        }
    
        // Additional field validation logic for specific payment types
        Id paymentType = payment.RecordTypeId;
        if (paymentType == [SELECT Id, Name FROM RecordType WHERE Name = 'Credit Card'][0].Id) {
            if (String.isBlank(payment.Credit_Card_Number__c) ||
                String.isBlank(payment.Credit_Card_Expiration_Month__c) ||
                String.isBlank(payment.Credit_Card_Expiration_Year__c) ||
                String.isBlank(payment.Credit_Card_Security_Code__c)) {
                return false;
            }
        } else if (paymentType == [SELECT Id, Name FROM RecordType WHERE Name = 'Check'][0].Id) {
            if (String.isBlank(payment.Check_Account_Number__c) ||
                String.isBlank(payment.Check_Routing_Number__c)) {
                return false;
            }
        }
    
        return true;
    }    
    
    // Map to convert months to 2 digits for authorize.net
    public static Map<String, String> monthMap = new Map<String, String>{
        'January' => '01',
        'February' => '02',
        'March' => '03',
        'April' => '04',
        'May' => '05',
        'June' => '06',
        'July' => '07',
        'August' => '08',
        'September' => '09',
        'October' => '10',
        'November' => '11',
        'December' => '12'
    };
}