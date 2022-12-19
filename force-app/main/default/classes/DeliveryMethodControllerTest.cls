@IsTest
public with sharing class DeliveryMethodControllerTest {
    @TestSetup
    static void setup(){
        TestDataUtility.setup();
    }
    
    @IsTest
    static void getDeliveryMethodsTest() {
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        cart.Status = 'Checkout';
        update cart;

        List<Map<String, Object>> deliveryMethods = DeliveryMethodController.getDeliveryMethods(cart.Id);
        // Testing sfdc_checkout.B2BCheckoutController.getDeliveryMethods() doesn't return the CartDeliveryGroupMethods consistently
        // Running multiple times it rarely assertEquals to 1 which is the expected result and instead it's very often 0
        // Cause may be due to async processes related to the records
        System.assertEquals(1, deliveryMethods.size());
        List<Map<String, Object>> deliveryMethods2 = DeliveryMethodController.getDeliveryMethods(null);
        System.assertEquals(null, deliveryMethods2);

    }
}