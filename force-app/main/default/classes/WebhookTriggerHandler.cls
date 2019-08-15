public without sharing class WebhookTriggerHandler extends TriggerHandler{

    private List<Webhook__c> newList;
    private List<Webhook__c> oldList;
    private Map<Id, Webhook__c> oldMap;
    private Map<Id, Webhook__c> newMap;

    @TestVisible static Boolean bypassTrigger = false;
    
    public WebhookTriggerHandler() {
        this.newList = (List<Webhook__c>) Trigger.new;
        this.oldList = (List<Webhook__c>) Trigger.old;
        this.oldMap = (Map<Id, Webhook__c>) Trigger.oldMap;
        this.newMap = (Map<Id, Webhook__c>) Trigger.newMap;
    }

    public override void afterInsert(){
        WebhookFactory.generate_events_from_map(newMap);

    }

    public override void afterUpdate(){
        // If Status is resubmit, then remake the event.
        WebhookFactory.generate_events_from_map(newMap);
    }

}
