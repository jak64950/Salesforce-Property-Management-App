@IsTest
private class API_ADNTest {
    @isTest 
    static void testAuthorizeCharge() {
        // Create a test request wrapper
        API_ADN.Req_Wrapper input = new API_ADN.Req_Wrapper();
        input.ordername = 'Test Order';
        input.ccnum = '4111111111111111';
        input.ccexp = '1224';
        input.ccsec = '123';
        input.amt = '100.00';
        input.firstname = 'John';
        input.lastname = 'Doe';
        input.billstreet = '123 Test Street';
        input.billcity = 'Test City';
        input.billstate = 'Test State';
        input.billzip = '12345';
        input.billcountry = 'Test Country';

        // Set up the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 1));

        // Call the authorizeCharge method
        API_ADN.Resp_Wrapper output = API_ADN.authorizeCharge(input);

        // Verify the response
        System.assertNotEquals(null, output);

        // Verify the response values
        System.assertEquals('12345', output.transid);
        System.assertEquals('1', output.respcode);
        System.assertEquals('ABC123', output.authcode);
        System.assertEquals('AVS123', output.avscode);
        System.assertEquals('CVV123', output.cvvcode);
        System.assertEquals('CAVV123', output.cavvcode);
        System.assertEquals('REF123', output.reftransid);
        System.assertEquals('1234567890', output.acctnum);
        System.assertEquals('Visa', output.accttype);
        System.assertEquals('NET123', output.nettransid);
        System.assertEquals('HASH123', output.tranhash);
        System.assertEquals('UserFieldValue123', output.ufvalue);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 3));
        output = API_ADN.authorizeCharge(input);
        // Verify the response
        System.assertEquals(null, output);
    }
}