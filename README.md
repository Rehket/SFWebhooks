# SF Webhooks
Some classes to create outbound JSON webhooks. 

## TO DO:
- [x] Tests...💥👍💪
- [ ] Maybe improve logging. 📑
- [ ] Permission sets❓
- [ ] UI/LWC app to create and monitor the webhooks? 📈
- [ ] Setup immediate mode/synchronous execution?❔❓

## Deployment

1. Pull the repo from github.
2. Deploy to your org.
3. Figure out the oobject permissions.
4. Insert a Webhook__c.
    ```java
    Account foos = [SELECT Id, Name FROM Account LIMIT 1];
    Webhook__c foo = new Webhook__c(
    URL__c = 'https://your_url_here.com',
    //Headers__c = '{"Content-Type": "application/json"}',
    Payload__c = JSON.serialize(foos)
    );

    insert foo;
    ```