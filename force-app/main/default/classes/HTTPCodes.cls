public without sharing class HTTPCodes {

    static Map<Integer, String> codes = new Map<Integer, String>{
        200=>'OK',
        201=>'CREATED',
        202=>'ACCEPTED',
        203=>'NON_AUTHORITATIVE_INFORMATION',
        204=>'NO_CONTENT',
        205=>'RESET_CONTENT',
        300=>'MULTIPLE_CHOICE',
        301=>'MOVED_PERMANENTLY',
        302=>'FOUND',
        303=>'SEE_OTHER',
        304=>'NOT_MODIFIED',
        305=>'USE_PROXY',
        306=>'unused',
        307=>'Temporary_Redirect',
        308=>'Permanent_Redirect'
    };

    @TestVisible
    static Set<Integer> successCodes = new Set<Integer>{
        200,
        201,
        202,
        203,
        204,
        205
    };

    @TestVisible
    static Set<Integer> redirectCodes = new Set<Integer>{
        300,
        301,
        302,
        303,
        304,
        305,
        306,
        307,
        308
    };

    public static Boolean isSuccessful(Integer statusCode){
        return successCodes.contains(statusCode);
    }

    public static Boolean isRedirect(Integer statusCode){
        return redirectCodes.contains(statusCode);
    }
}
