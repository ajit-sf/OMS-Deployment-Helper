@IsTest
public class checkoutSessionWaitControllerTest {
    @TestSetup
    static void setup(){
        TestDataUtility.setup();
    }

    @IsTest
    static void getCheckoutSessionTest() {
        CartCheckoutSession testSession = [SELECT Id FROM CartCheckoutSession LIMIT 1];
        CartCheckoutSession checkoutSession = checkoutSessionWaitController.getCheckoutSession(testSession.Id);
        System.assertEquals(false, checkoutSession.isProcessing);
        DELETE testSession;
        checkoutSession = checkoutSessionWaitController.getCheckoutSession(testSession.Id);
        System.assertEquals(null, checkoutSession);
    }
}