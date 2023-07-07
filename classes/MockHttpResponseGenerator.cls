public class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    private Integer option;

    public MockHttpResponseGenerator(Integer statusCode, Integer option) {
        this.option = option;
        this.statusCode = statusCode;
    }

    public HttpResponse respond(HttpRequest request) {
        // Verify the HTTP request properties
        System.assertEquals('https://apitest.authorize.net/xml/v1/request.api', request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        System.assertEquals('application/json', request.getHeader('Content-Type'));

        // Create a mock HTTP response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        
        if (statusCode == 200 && option == 1) {
            String responseBody = '\uFEFF' + '{' +
                '"transactionResponse": {' +
                    '"transId": "12345",' +
                    '"responseCode": "1",' +
                    '"authCode": "ABC123",' +
                    '"avsResultCode": "AVS123",' +
                    '"cvvResultCode": "CVV123",' +
                    '"cavvResultCode": "CAVV123",' +
                    '"refTransId": "REF123",' +
                    '"accountNumber": "1234567890",' +
                    '"accountType": "Visa",' +
                    '"networkTransId": "NET123",' +
                    '"transHashSha2": "HASH123",' +
                    '"userFields": [{' +
                        '"value": "UserFieldValue123"' +
                    '}]' +
                '}' +
            '}';
    
            response.setBody(responseBody);
            
        } else if (statusCode == 200 && option == 2) {
            String responseBody = '\uFEFF' + '{' +
                '"transactionResponse": {' +
                    '"transId": "12345",' +
                    '"responseCode": "2",' +
                    '"authCode": "ABC123",' +
                    '"avsResultCode": "AVS123",' +
                    '"cvvResultCode": "CVV123",' +
                    '"cavvResultCode": "CAVV123",' +
                    '"refTransId": "REF123",' +
                    '"accountNumber": "1234567890",' +
                    '"accountType": "Visa",' +
                    '"networkTransId": "NET123",' +
                    '"transHashSha2": "HASH123",' +
                    '"userFields": [{' +
                        '"value": "UserFieldValue123"' +
                    '}]' +
                '}' +
            '}';
    
            response.setBody(responseBody);
        } else {
            String responseBody = '\uFEFF' + '{' +
                '"transactionResponse": {' +
                    '"transId": "12345",' +
                    '"responseCode": "3",' +
                    '"authCode": "ABC123",' +
                    '"avsResultCode": "",' +
                    '"cvvResultCode": "",' +
                    '"cavvResultCode": "",' +
                    '"refTransId": "REF123",' +
                    '"accountNumber": "",' +
                    '"accountType": "",' +
                    '"networkTransId": "NET123",' +
                    '"transHashSha2": "HASH123",' +
                    '"userFields": [{' +
                        '"value": "UserFieldValue123"' +
                    '}]' +
                '}' +
            '}';
    
            response.setBody(responseBody);
        }

        return response;
    }
}