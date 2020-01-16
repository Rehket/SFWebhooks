
/*********************
* Dispatch
* @author Rehket, 15 January 2020
*/
public with sharing virtual class Dispatch implements Queueable, Database.AllowsCallouts {

    class DispatchException extends Exception {}

    String class_name = String.valueOf(this).split(':')[0];
    Dispatch_Setting__c dispatch_setting = [
        SELECT 
            Name,
            Dispatch_Query__c,
            Remote_URL__c,
            Headers__c,
            Order_By_Field_API_Name__c,
            Order_Direction__c,
            Status_Field_API_Name__c
        FROM Dispatch_Setting__c WHERE Name = :class_name
    ];


    
    public void execute(QueueableContext context) {
        
        String dispatch_query = this.dispatch_setting.Dispatch_Query__c + ' AND Status__c = \'NEW\' ORDER BY ' + this.dispatch_setting.Order_By_Field_API_Name__c + ' ' + this.dispatch_setting.Order_Direction__c +  ' LIMIT 1';
        SObject dispatch_object = Database.query(dispatch_query);
        if(dispatch_object == null)
            throw new DispatchException('Retrieving dispatch object failed: ' + dispatch_query);

        // Make Request & Send Request
        HttpResponse dispatch_response = RequestFactory.do_callout(this.dispatch_setting.Headers__c, 'POST', JSON.serialize(dispatch_object), this.dispatch_setting.Remote_URL__c);

        // On Success Action

        // On Fail Action

    }



    private void validate(){
        
        if(String.isBlank(this.dispatch_setting.Remote_URL__c))
            throw new DispatchException('The dispatch metadata associate with this seems to be missing the Remote_URL__c and is not valid.' + this.dispatch_setting); 

        if(String.isBlank(this.dispatch_setting.Status_Field_API_Name__c))
            throw new DispatchException('The dispatch metadata associate with this seems to be missing the Status_Field_API_Name__c and is not valid.' + this.dispatch_setting); 
    }
}
