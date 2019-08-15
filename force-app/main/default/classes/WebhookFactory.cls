public without sharing class WebhookFactory {

    public static void generate_events_from_map(Map<Id, Webhook__c> my_webhook_map){
        List<Webhook_Event__e> events_to_publish = new List<Webhook_Event__e>();
        List<Webhook__c> webhooks_to_update = new List<Webhook__c>();

        for(Id webhook_id: my_webhook_map.keySet()){
            Webhook__c my_hook = my_webhook_map.get(webhook_id);
            if (my_hook.Execution_Order__c == 'ASYNCHRONOUS' && (my_hook.Status__c == 'NEW' || my_hook.Status__c == 'RESUBMIT')) {
                
                events_to_publish.add(new Webhook_Event__e(
                    URL__c = my_hook.URL__c,
                    Headers__c = my_hook.Headers__c,
                    Payload__c = my_hook.Payload__c,
                    Webhook_Id__c = my_hook.Id
                ));
                Webhook__c my_new_hook = new Webhook__c(Id=my_hook.Id, Status__c = 'PROCESSED');
                webhooks_to_update.add(my_new_hook);
            }
        }

        if ( !( webhooks_to_update.isEmpty() || events_to_publish.isEmpty() ) ){
            update webhooks_to_update;
            List<Database.SaveResult> results = EventBus.publish(events_to_publish);
        }
    }

    @future(callout=true)
    public static void make_callout_from_webhook(String URL, String headers, String payload, String webhook_id){
        Map<String, String> header_map = (Map<String, String>)JSON.deserialize(headers, Map<String, String>.class);
        
        HttpRequest req = new HttpRequest();
        for( String k: header_map.keySet()){
            req.setHeader(k, header_map.get(k));
        }
        
        req.setBody(payload);
        req.setMethod('POST');
        req.setEndpoint( URL );

        Http my_http = new Http();
        HTTPResponse res = my_http.send(req);

        Webhook__c my_webhook_obj = new Webhook__c(
            Id= webhook_id,
            StatusCode__c = res.getStatusCode()
        );

        update my_webhook_obj;
    }

}