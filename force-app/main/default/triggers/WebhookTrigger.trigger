trigger WebhookTrigger on Webhook__c (before insert, after insert, before update, after update, 
                  before delete, after delete, after undelete  ) {
    new WebhookTriggerHandler().run();

}