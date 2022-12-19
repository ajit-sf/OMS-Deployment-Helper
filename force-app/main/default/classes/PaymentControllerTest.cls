@IsTest
public class PaymentControllerTest {
    @TestSetup
    static void setup(){
        TestDataUtility.setup();
    }

    @IsTest
    static void getPaymentInfoTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Map<String, Object> paymentInfo = PaymentController.getPaymentInfo(acc.Id, cart.Id);
        System.assertEquals('12345', paymentInfo.get('purchaseOrderNumber'));

        List<Map<String, Object>> addresses = (List<Map<String, Object>>)paymentInfo.get('addresses');
        System.assertEquals(2, addresses.size());
    }

    @IsTest
    static void setPaymentTest() {
        String paymentType = 'PurchaseOrderNumber';
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Map<String, Object> billingAddress = getTestBillingAddress();
        Map<String, Object> paymentInfo = getTestPaymentInfo();
        PaymentController.setPayment(paymentType, cart.Id, billingAddress, paymentInfo);
        cart = [SELECT Id, PoNumber FROM WebCart WHERE Id = :cart.Id];
        System.assertNotEquals(null, cart.PoNumber);

        paymentType = 'Credit Card';
        PaymentController.setPayment(paymentType, cart.Id, billingAddress, paymentInfo);
        cart = [SELECT Id, PoNumber FROM WebCart WHERE Id = :cart.Id];
        System.assertEquals(null, cart.PoNumber);
    }

    private static Map<String, Object> getTestBillingAddress() {
        Map<String, Object> billingAddress = new Map<String, Object>();
        billingAddress.put('street', '123 Test St');
        billingAddress.put('city', 'Test City');
        billingAddress.put('province', 'Test State');
        billingAddress.put('postalCode', '012345');
        billingAddress.put('country', 'Test Country');
        return billingAddress;
    }

    private static Map<String, Object> getTestPaymentInfo() {
        Map<String, Object> paymentInfo = new Map<String, Object>();
        paymentInfo.put('poNumber', '12345');
        paymentInfo.put('cardHolderName', 'Test Buyer');
        paymentInfo.put('cardNumber', '444444444444444');
        paymentInfo.put('cardType', 'Visa');
        paymentInfo.put('cvv', '321');
        paymentInfo.put('expiryMonth', '10');
        paymentInfo.put('expiryYear', '2030');
        return paymentInfo;
    }
}