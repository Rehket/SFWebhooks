public with sharing class WebhookBase {
    String queued_timestampz;
    String timestampz = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
    String webhook_id;

    @testVisible
    Object payload;
    String instance_url = URL.getOrgDomainUrl().toExternalForm();
    
    public WebhookBase(String queued_timestampz, String webhook_id) {

        // "2014-02-01T09:28:56.321-10:00"
        this.queued_timestampz = queued_timestampz; //Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        this.webhook_id = webhook_id;
        this.payload = 'REPLACE_TOKEN';
    
    }

    public Boolean isValid(){
        String json_payload = JSON.serialize(this);
        // Events can't be larger than 1mb, or about 1048576 characters, and text field cant be more than 131072 characters.
        if (json_payload.length() > 131072) 
            return false; 
        return true;
    }
}