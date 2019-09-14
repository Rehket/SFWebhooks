@isTest
global without sharing class Webhook_Test {

    global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            switch on req.getEndpoint() {
                when 'https://www.good_response.com' {
                    res.setStatusCode(200);
                }
                when else {
                    res.setStatusCode(500);
                }
            }
            return res;
        }
    }

    @IsTest
    static void check_in_progress_request(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Webhook__c my_request = new Webhook__c(
            URL__c = 'https://www.good_response.com',
            // Headers__c = '{"Content-Type": "application/json"}',
            Payload__c = '{"hello": "world"}'
        );

        insert my_request;
        Test.stopTest();
        Webhook__c my_completed_request = [SELECT Id, Status__c, StatusCode__c FROM Webhook__c WHERE Id =: my_request.Id LIMIT 1];

        System.assertEquals('INPROGRESS', my_completed_request.Status__c);
    }

    @IsTest
    static void check_after_event(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Webhook__c my_request = new Webhook__c(
            URL__c = 'https://www.good_response.com',
            // Headers__c = '{"Content-Type": "application/json"}',
            Payload__c = '{"hello": "world"}'
        );

        insert my_request;
        Test.getEventBus().deliver();

        Test.stopTest();
        Webhook__c my_completed_request = [SELECT Id, Status__c, StatusCode__c FROM Webhook__c WHERE Id =: my_request.Id LIMIT 1];

        System.assertEquals('PROCESSED', my_completed_request.Status__c);
        System.assertEquals(200, my_completed_request.StatusCode__c);
    }

    @IsTest
    static void check_after_failed(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Webhook__c my_request = new Webhook__c(
            URL__c = 'https://www.good_responwwwwwwse.com',
            // Headers__c = '{"Content-Type": "application/json"}',
            Payload__c = '{"hello": "world"}'
        );

        insert my_request;
        Test.getEventBus().deliver();

        Test.stopTest();
        Webhook__c my_completed_request = [SELECT Id, Status__c, StatusCode__c FROM Webhook__c WHERE Id =: my_request.Id LIMIT 1];

        System.assertEquals('FAILED', my_completed_request.Status__c);
        System.assertEquals(500, my_completed_request.StatusCode__c);
    }

    @IsTest
    static void should_raise_exception(){
        
        Test.startTest();
        Webhook__c my_request = new Webhook__c(
            URL__c = 'https://www.good_responwwwwwwse.com',
            // Headers__c = '{"Content-Type": "application/json"}',
            Payload__c = '{"hello": "world"}'
        );

        insert my_request;
        Test.getEventBus().deliver();

        Test.stopTest();
        Webhook__c my_completed_request = [SELECT Id, Status__c, StatusCode__c FROM Webhook__c WHERE Id =: my_request.Id LIMIT 1];

        System.assertEquals('FAILED', my_completed_request.Status__c);
        System.assertEquals(null, my_completed_request.StatusCode__c);
    }

    @IsTest
    static void test_webhook_base_valid_check(){

        WebhookBase my_hook = new WebhookBase(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'), '21123123123');

        my_hook.payload = 'e'.rightPad(131072, '0');
        System.assertEquals(false, my_hook.isValid());
        my_hook.payload = 'e'.rightPad(130877, '0'); // This pads the payload to mare the JSON string the max possible size.
        System.assert(my_hook.isValid(), 'Length is ' + String.valueOf(JSON.serialize(my_hook).length()));
    }
}