@isTest
public without sharing class HTTPCodes_Test {
  @isTest
  public static void test_isSuccess() {
    for(Integer code: HTTPCodes.successCodes){
      System.assert(HTTPCodes.isSuccessful(code));
    }
  }
}
