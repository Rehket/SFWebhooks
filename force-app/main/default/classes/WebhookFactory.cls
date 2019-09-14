public without sharing class WebhookFactory {

    public static void generate_events_from_map(Map<Id, Webhook__c> my_webhook_map){
        List<Webhook_Event__e> events_to_publish = new List<Webhook_Event__e>();
        List<Webhook__c> webhooks_to_update = new List<Webhook__c>();

        for(Id webhook_id: my_webhook_map.keySet()){
            Webhook__c my_hook = my_webhook_map.get(webhook_id);
            if (my_hook.Execution_Order__c == 'IMMEDIATE' && (my_hook.Status__c == 'NEW' || my_hook.Status__c == 'RESUBMIT')) {
                
                events_to_publish.add(new Webhook_Event__e(
                    Webhook_Id__c = my_hook.Id
                ));
                Webhook__c my_new_hook = new Webhook__c(Id=my_hook.Id, Status__c = 'INPROGRESS');
                webhooks_to_update.add(my_new_hook);
            }
        }

        if ( !( webhooks_to_update.isEmpty() || events_to_publish.isEmpty() ) ){
            update webhooks_to_update;
            List<Database.SaveResult> results = EventBus.publish(events_to_publish);
        }
    }

    @future(callout=true)
    public static void make_callout_from_webhook(String webhook_id){
        
        
        Webhook__c my_webhook = [SELECT Id, Payload__c, Object_Payload_Id__c, Headers__c, URL__c, CreatedDate FROM Webhook__c WHERE Id =: webhook_id LIMIT 1];
        Map<String, String> header_map = (Map<String, String>)JSON.deserialize(my_webhook.Headers__c, Map<String, String>.class);

        HttpRequest req = new HttpRequest();
        for( String k: header_map.keySet() ){
            req.setHeader(k, header_map.get(k));
        }
        
        
        String final_payload = JSON.serialize(new WebhookBase(Datetime.valueOf(my_webhook.CreatedDate).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'), webhook_id));

        if (String.isBlank(my_webhook.Object_Payload_Id__c)){
            req.setBody(final_payload.replace('"REPLACE_TOKEN"', my_webhook.Payload__c));
        } else {
            
            req.setBody(final_payload.replace('"REPLACE_TOKEN"', build_json_object_payload(my_webhook.Object_Payload_Id__c)));
        }
            
        req.setMethod('POST');
        req.setEndpoint( my_webhook.URL__c );

        Http my_http = new Http();
        Webhook__c my_webhook_obj = new Webhook__c();

        try {
            HTTPResponse res = my_http.send(req);
            my_webhook_obj.Id = webhook_id;
            my_webhook_obj.StatusCode__c = res.getStatusCode();
            my_webhook_obj.Status__c = res.getStatusCode() < 300 ? 'PROCESSED': 'FAILED';

            
        } catch(Exception e) {
            my_webhook_obj.Id= webhook_id;
            my_webhook_obj.Status__c = 'FAILED';
            my_webhook_obj.Message__c = e.getMessage();
        }

        update my_webhook_obj;
    }


    // Need to write test
    static String build_json_object_payload(String object_id){

        String query_string = '';
        Schema.SObjectType token = Id.valueOf(object_id).getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
        for (String field: field_map.keySet())
            query_string += field + ', ';
        query_string = query_string.removeEnd(', ');
        System.debug(query_string);

        // Gotta do this to get the fields dropped for null values.
        SObject payload = Database.query('SELECT ' + query_string + ' FROM ' + dr.getName() + ' LIMIT 1');
        for (String field: field_map.keySet()){
            if(field_map.get(field).getDescribe().isUpdateable())
                payload.put( field, (payload.isSet(field)  ? payload.get(field): null) );
        }
        
        return JSON.serialize(payload);

    }

}