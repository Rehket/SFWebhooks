public without sharing class WebhookEventTriggerHandler  extends TriggerHandler {

    private List<Webhook_Event__e> newList;
    private List<Webhook_Event__e> oldList;
    private Map<Id, Webhook_Event__e> oldMap;
    private Map<Id, Webhook_Event__e> newMap;

    @TestVisible static Boolean bypassTrigger = false;
    
    public WebhookEventTriggerHandler() {
        this.newList = (List<Webhook_Event__e>) Trigger.new;
        this.oldList = (List<Webhook_Event__e>) Trigger.old;
        this.oldMap = (Map<Id, Webhook_Event__e>) Trigger.oldMap;
        this.newMap = (Map<Id, Webhook_Event__e>) Trigger.newMap;
    }

    public override void afterInsert(){
        for (Webhook_Event__e webhook: this.newList){
            WebhookFactory.make_callout_from_webhook(webhook.URL__c, webhook.Headers__c, webhook.Payload__c, webhook.Webhook_Id__c);
        }
    }
}