
// Execute Me Anomymously
Account foos = [SELECT Id, Name FROM Account LIMIT 1];
Webhook__c foo = new Webhook__c(
    URL__c = 'https://your_url_here.com',
    //Headers__c = '{"Content-Type": "application/json"}',
    Payload__c = JSON.serialize(foos)
);

insert foo;