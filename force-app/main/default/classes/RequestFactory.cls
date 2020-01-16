public with sharing class RequestFactory {

    class RequestException extends Exception{}

    
    public class JSONBase {

        // "2014-02-01T09:28:56.321-10:00"
        String timestampz = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'); //Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        String payload = 'REPLACE_TOKEN';

        public String toJSON(){
            return JSON.Serialize(this);
        }
    
    }

    // WrapXML Payload
    private static String wrap_xml_payload(String xml_payload){
        return '<xml_wrapper>' + xml_payload + '</xml_wrapper>';
    }

    public static HttpRequest build_request(String json_header_map, String request_method, String payload, String request_url){
        HttpRequest req = new HttpRequest();
        Map<String, String> header_map = (Map<String, String>)JSON.deserialize(json_header_map, Map<String, String>.class);

        for( String k: header_map.keySet() ){
            req.setHeader(k, header_map.get(k));
        }
        req.setMethod(request_method);
        req.setBody((req.getHeader('Content-Type') == 'application/json' ?  new JSONBase().toJSON().replace('"REPLACE_TOKEN"', payload) : wrap_xml_payload(payload)));
        req.setEndpoint(request_url);

        return req;
    }

    public static HTTPResponse do_callout(String json_header_map, String request_method, String payload, String request_url){
        HttpRequest req = build_request(json_header_map, request_method, payload, request_url);
        Http req_http = new Http();
        HttpResponse res;
        try {
            res = req_http.send(req);
            if(! String.valueOf(res.getStatusCode()).startsWith('2'))
                throw new RequestException('Callout failed with status: ' + res.getStatusCode() + '\n' + res.getBody());
        } catch(Exception e) {
            // TODO: Add Real Error Handling or Logging
           System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return res;
    }


}
