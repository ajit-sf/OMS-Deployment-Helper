@isTest
public class AuthorizeTokenizedPaymentTest {
    
    @TestSetup
    static void setup(){
        TestDataUtility.setup();
    }
    
    @IsTest
    static void authorizePaymentInfoTest(){
        AuthorizeTokenizedPayment.AuthorizeTokenizedPaymentRequest rq = new AuthorizeTokenizedPayment.AuthorizeTokenizedPaymentRequest();
        Webcart cart = [SELECT id from Webcart LIMIT 1];
        rq.cartId = cart.Id;
        List<AuthorizeTokenizedPayment.AuthorizeTokenizedPaymentRequest> rqlist = new List<AuthorizeTokenizedPayment.AuthorizeTokenizedPaymentRequest>();
        rqlist.add(rq);
        List<string> authorizeRespone =  AuthorizeTokenizedPayment.authorizePaymentInfo(rqlist);
        
        
    }

}