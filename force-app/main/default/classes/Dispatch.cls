/*********************
 * Dispatch
 * @author Rehket, 15 January 2020
 */
public without sharing virtual class Dispatch implements Queueable, Database.AllowsCallouts {
  @TestVisible
  class PayloadBase {
    String timestampz;

    @TestVisible
    String org_id = UserInfo.getOrganizationId();

    @TestVisible
    SObject payload;

    @TestVisible
    PayloadBase(SObject payload) {
      this.timestampz = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
      this.payload = payload;
      System.debug(this);
    }
    public String toJSON() {
      System.debug(this);
      return JSON.serialize(this);
    }
  }

  class DispatchException extends Exception {
  }

  String class_name = String.valueOf(this).split(':')[0];
  Dispatch_Setting__c dispatch_setting;
  public Dispatch() {
    try {
      dispatch_setting = [
        SELECT
          Name,
          Dispatch_Query__c,
          Remote_URL__c,
          Headers__c,
          Order_By_Field_API_Name__c,
          Order_Direction__c,
          Status_Field_API_Name__c,
          Chain__c,
          NamedCredential__c
        FROM Dispatch_Setting__c
        WHERE Name = :class_name
      ];
    } catch (QueryException e) {
      throw new DispatchException(
        'No dispatch setting found for class: ' +
        class_name +
        ' ' +
        e.getMessage()
      );
    }
  }

  @TestVisible
  String json_base(SObject payload) {
    return '{"timestampz": "' +
      Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') +
      '", "payload": "REPLACE_TOKEN"}'
        .replace('"REPLACE_TOKEN"', JSON.serialize(payload));
  }

  @TestVisible
  String xml_base(SObject payload) {
    String header = '<?xml version="1.0" encoding="UTF-8"?>';
    String xml_payload =
      '<body><SObject xsi:type="' +
      payload.getSObjectType() +
      '"/><payload>';
    for (String field_name : payload.getPopulatedFieldsAsMap().keySet()) {
      xml_payload =
        xml_payload +
        '<' +
        field_name +
        '>' +
        payload.get(field_name) +
        '</' +
        field_name +
        '>';
    }
    return header + xml_payload + '</payload></body>';
  }

  public String get_payload(String json_headers, SObject payload) {
    Map<String, String> headers = (Map<String, String>) JSON.deserialize(
      json_headers,
      Map<String, String>.class
    );
    PayloadBase my_payload = new PayloadBase(payload);
    System.debug(my_payload);
    return (headers.get('Content-Type') == 'application/json'
      ? my_payload.toJSON()
      : xml_base(payload));
  }

  public void execute(QueueableContext context) {
    String dispatch_query =
      this.dispatch_setting.Dispatch_Query__c +
      ' ' +
      this.dispatch_setting.Status_Field_API_Name__c +
      ' = \'NEW\' ORDER BY ' +
      this.dispatch_setting.Order_By_Field_API_Name__c +
      ' ' +
      this.dispatch_setting.Order_Direction__c +
      ' LIMIT 2';
    List<SObject> dispatch_objects = Database.query(dispatch_query);
    if (dispatch_objects.isEmpty())
      throw new DispatchException(
        'Retrieving dispatch object failed: ' + dispatch_query
      );

    // Get or refresh the access token
    if (String.isNotBlank(dispatch_setting.NamedCredential__c)) {
      String token = CachedCredential.getCredentialFromCache(
        dispatch_setting.NamedCredential__c
      );
      Map<String, String> headers = (Map<String, String>) JSON.deserialize(
        dispatch_setting.Headers__c,
        Map<String, String>.class
      );
      headers.put('Authorization', 'Bearer ' + token);
      dispatch_setting.Headers__c = JSON.serialize(headers);
    }

    if (Test.isRunningTest()) {
      if (String.isNotBlank(dispatch_setting.NamedCredential__c)) {
        System.assert(dispatch_setting.Headers__c.contains('some_big_token'));
      }
      // Test.setMock(HttpCalloutMock.class, new Dispatch_TC.DispatchMock());
    }

    // Make Request & Send Request
    HttpResponse dispatch_response;
    try {
      System.debug(
        LoggingLevel.DEBUG,
        get_payload(this.dispatch_setting.Headers__c, dispatch_objects[0])
      );
      dispatch_response = RequestFactory.do_callout(
        this.dispatch_setting.Headers__c,
        'POST',
        get_payload(this.dispatch_setting.Headers__c, dispatch_objects[0]),
        this.dispatch_setting.Remote_URL__c
      );
      if (String.valueOf(dispatch_response.getStatusCode()).startsWith('2'))
        dispatch_objects[0]
          .put(this.dispatch_setting.Status_Field_API_Name__c, 'PROCESSED');
      else {
        dispatch_objects[0]
          .put(this.dispatch_setting.Status_Field_API_Name__c, 'FAILED');
        dispatch_objects[0]
          .put('Response_Message__c', dispatch_response.getBody());
      }
    } catch (RequestFactory.RequestException e) {
      System.debug(LoggingLevel.ERROR, 'Callout Failed. ' + e.getMessage());
      System.debug(LoggingLevel.ERROR, e.getStackTraceString());
      dispatch_objects[0]
        .put(this.dispatch_setting.Status_Field_API_Name__c, 'FAILED');
    }
    update dispatch_objects[0];

    if (dispatch_objects.size() > 1 && this.dispatch_setting.Chain__c)
      System.enqueueJob(this);
  }

  @TestVisible
  private void validate() {
    if (String.isBlank(this.dispatch_setting.Remote_URL__c))
      throw new DispatchException(
        'The dispatch metadata associate with this seems to be missing the Remote_URL__c and is not valid.' +
        this.dispatch_setting
      );

    if (String.isBlank(this.dispatch_setting.Status_Field_API_Name__c))
      throw new DispatchException(
        'The dispatch metadata associate with this seems to be missing the Status_Field_API_Name__c and is not valid.' +
        this.dispatch_setting
      );
  }
}
