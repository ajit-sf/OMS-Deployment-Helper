public with sharing class DeliveryMethodController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getDeliveryMethods(String cartId) {
        if(String.isBlank(cartId)) {
            return null;
        }

        return sfdc_checkout.B2BCheckoutController.getDeliveryMethods(cartId);
    }
}