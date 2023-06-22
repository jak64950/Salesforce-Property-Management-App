public with sharing class API_ADN {
    //variables to hold our login credentials
    public static string apiLogin;
    public static string transKey;

    public static void getCreds(){        
        //get api key values
        AuthorizeDotNet_Setting__mdt apiloginid = AuthorizeDotNet_Setting__mdt.getInstance('API_Login');
        AuthorizeDotNet_Setting__mdt apitranskey = AuthorizeDotNet_Setting__mdt.getInstance('Trans_Key');
        apiLogin = apiloginid.Value__c;
        transKey = apitranskey.Value__c;
    }

    public static Resp_Wrapper authorizeCharge (Req_Wrapper input) {
        //reusable method for getting Authorize.Net credentials
        getCreds();
  
        //Construct the request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api'); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
      
        //build request payload, must build manually as order needs to be guaranteed
        String payloadJson = '{' +
            '"createTransactionRequest": {' +
                '"merchantAuthentication": {' +
                    '"name": "' + apiLogin + '",' +
                    '"transactionKey": "' + transKey + '"' +
                '},' +
                '"transactionRequest": {' +
                    '"transactionType": "authCaptureTransaction",' +
                    '"amount": "' + input.amt + '",' +
                    '"payment": {' +
                        '"creditCard": {' +
                            '"cardNumber": "' + input.ccnum + '",' +
                            '"expirationDate": "' + input.ccexp + '",' +
                            '"cardCode": "' + input.ccsec + '"' +
                        '}' +
                    '},' +
                    '"billTo": {' +
                        '"firstName": "' + input.firstname + '",' +
                        '"lastName": "' + input.lastname + '",' +
                        '"address": "' + input.billstreet + '",' +
                        '"city": "' + input.billcity + '",' +
                        '"state": "' + input.billstate + '",' +
                        '"zip": "' + input.billzip + '",' +
                        '"country": "' + input.billcountry + '"' +
                    '},' +
                    '"userFields": {' +
                        '"userField": {' +
                            '"name": "OrderDescription",' +
                            '"value": "' + input.ordername + '"' +
                        '}' +
                    '}' +
                '}' +
            '}' +
        '}';
        req.setBody(payloadJson);

        // Send the request
        HttpResponse res = new Http().send(req);

        // Process the response
        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody().trim();
        
            // Remove the BOM character if present
            if (responseBody.startsWith('\uFEFF')) {
                responseBody = responseBody.substring(1);
            }
        
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> transactionResponse = (Map<String, Object>) response.get('transactionResponse');

            // Construct the response wrapper
            API_ADN.Resp_Wrapper output = new API_ADN.Resp_Wrapper();
            output.transid = (String) transactionResponse.get('transId');
            output.respcode = (String) transactionResponse.get('responseCode');
            output.authcode = (String) transactionResponse.get('authCode');
            output.avscode = (String) transactionResponse.get('avsResultCode');
            output.cvvcode = (String) transactionResponse.get('cvvResultCode');
            output.cavvcode = (String) transactionResponse.get('cavvResultCode');
            output.reftransid = (String) transactionResponse.get('refTransId');
            output.acctnum = (String) transactionResponse.get('accountNumber');
            output.accttype = (String) transactionResponse.get('accountType');
            output.nettransid = (String) transactionResponse.get('networkTransId');
            output.tranhash = (String) transactionResponse.get('transHashSha2');
            List<Object> userfields = (List<Object>) transactionResponse.get('userFields');    
            Map<String, Object> userfield = (Map<String, Object>) userfields[0];
            output.ufvalue = (String) userfield.get('value');
            return output;
        } else {
            return null;
        }
    }

    // Wrapper class for the request payload
    public class Req_Wrapper {
        public String ordername;
        public String ccnum;
        public String ccexp;
        public String ccsec;
        public String amt;
        public String firstname;
        public String lastname;
        public String billstreet;
        public String billcity;
        public String billstate;
        public String billzip;
        public String billcountry;
        public String transid;
        public String routingnumber;
        public String accountnumber;
        public String bankaccounttype;
        public String bankname;
        public String bankaccountname;

        public Req_Wrapper() {}
    }

    // Wrapper class for the response
    public class Resp_Wrapper{
        public string transid;
        public string respcode;
        public string authcode;
        public string avscode;
        public string cvvcode;
        public string cavvcode;
        public string reftransid;
        public string acctnum;
        public string accttype;
        public string nettransid;
        public string tranhash;
        public string ufvalue;

        public Resp_Wrapper() {}
    }
}