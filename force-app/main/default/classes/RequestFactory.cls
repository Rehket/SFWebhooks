public with sharing class RequestFactory {

    Map<String, String> header_map;
    String request_method;
    String request_url;
    String request_body;
    HttpRequest req;
    HTTPResponse res;
    Http req_http;

    class RequestException extends Exception{}

    public RequestFactory(String json_header_map, String request_method, String payload, String request_url) {
        this.header_map = (Map<String, String>)JSON.deserialize(json_header_map, Map<String, String>.class);
        this.request_method = request_method;
        this.request_url = request_url;
        this.req_http = new Http();
        this.request_body = payload;
    }

    public HttpRequest build_request(){
        this.req = new HttpRequest();
        for( String k: this.header_map.keySet() ){
            this.req.setHeader(k, this.header_map.get(k));
        }
        this.req.setMethod(this.request_method);
        this.req.setBody(this.request_body);
        this.req.setEndpoint(this.request_url);

        return this.req;
    }

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

    public HTTPResponse do_callout(){
        try {
            this.res = this.req_http.send(req);
            if(! String.valueOf(this.res.getStatusCode()).startsWith('2'))
                throw new RequestException('Callout failed with status: ' + this.res.getStatusCode() + '\n' + this.res.getBody());
        } catch(Exception e) {
            // TODO: Add Real Error Handling or Logging
           System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return this.res;
    }


}
