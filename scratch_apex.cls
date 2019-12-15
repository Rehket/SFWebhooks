


SObject foos = [SELECT Id FROM Case LIMIT 1];
String query_string = '';
Schema.SObjectType token = foos.Id.getSObjectType();
Schema.DescribeSObjectResult dr = token.getDescribe();
Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
for (String field: field_map.keySet())
    query_string += field + ', ';
query_string = query_string.removeEnd(', ');
System.debug(query_string);

SObject payload = Database.query('SELECT ' + query_string + ' FROM ' + dr.getName() + ' LIMIT 1');
for (String field: field_map.keySet()){
    if(field_map.get(field).getDescribe().isUpdateable())
        payload.put( field, (payload.isSet(field)  ? payload.get(field): null) );
}
    
System.debug(payload);


// Execute Me Anomymously
SObject foos = [SELECT Id FROM Case LIMIT 1];
Webhook__c foo = new Webhook__c(
    URL__c = 'https://7f474dd8.ngrok.io/api/v1/salesforce/webhook',
    Object_Payload_Id__c = foos.Id
);

insert foo;