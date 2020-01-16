
/*********************
* Dispatch
* @author Rehket, 15 January 2020
*/
public with sharing virtual class Dispatch implements Queueable, {

    class DispatchException extends Exception {}

    String class_name = String.valueOf(this).split(':')[0];
    DispatchSetting__mdt dispatch_setting = [
        SELECT 
            Name__c, 
            Dispatch_Query__c, 
            Remote_URL__c, 
            Headers__c, 
            Order_By_Field_API_Name__c, 
            Order_Direction__c,
            Status_Field_API_Name__c
        FROM DispatchSetting__mdt
    ];
    
    public void execute(QueueableContext context) {
        
        SObject dispatch_object = Database.query(dispatch_setting.Dispatch_Query__c + ' ORDER BY ' + dispatch_setting.Order_By_Field_API_Name__c + ' ' + dispatch_setting.Order_Direction__c +  ' LIMIT 1');




    }

    private void validate(){
        
        if(String.isBlank(this.dispatch_setting.Remote_URL__c))
            throw new DispatchException('The dispatch metadata associate with this seems to be missing the Remote_URL__c and is not valid.' + this.dispatch_setting); 

        if(String.isBlank(this.dispatch_setting.Status_Field_API_Name__c))
            throw new DispatchException('The dispatch metadata associate with this seems to be missing the Status_Field_API_Name__c and is not valid.' + this.dispatch_setting); 
    }
}
