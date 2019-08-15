trigger WebhookEventTrigger on Webhook_Event__e (after insert) {
    new WebhookEventTriggerHandler().run();

}