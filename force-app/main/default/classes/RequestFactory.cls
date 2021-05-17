public with sharing class Request {

    class RequestException extends Exception{}


    public static HttpRequest build_request(String json_header_map, String request_method, String payload, String request_url){
        HttpRequest req = new HttpRequest();
        Map<String, String> header_map = (Map<String, String>)JSON.deserialize(json_header_map, Map<String, String>.class);

        for( String k: header_map.keySet() ){
            req.setHeader(k, header_map.get(k));
        }
        req.setMethod(request_method);
        req.setBody(payload);
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
        } catch(CalloutException e) {
            // TODO: Add Real Error Handling or Logging
           System.debug(LoggingLevel.ERROR, e.getMessage());
           throw new RequestException('An error occured while making the callout.');
        }
        return res;
    }


}
