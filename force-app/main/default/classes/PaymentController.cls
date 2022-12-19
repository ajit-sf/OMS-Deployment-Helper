/**
    Author:         Derrick Vuong
    Company:        Salesforce
    Description:    PaymentController.cls
    Date:           07-Oct-2022

    TODO:
    - 
**/
public with sharing class PaymentController {
    private static final String PAYMENT_STATE = 'Payment And Billing Address';
    
    @AuraEnabled
    public static Map<String, Object> getPaymentInfo(String accountOrRelatedId, String cartId) {
        // Get the effectiveAccountId
        // String accountId = B2BUtils.getUserAccountID();
        String accountId = OMSOrderEntry.Utility.resolveAccountId(accountOrRelatedId);
        
        // Get the 'purchaseOrderNumber' from the WebCart
        WebCart webCart = [SELECT Id, BillingAddress, PoNumber FROM WebCart WHERE Id=:cartId
                           WITH SECURITY_ENFORCED];

        Map<String, Object> paymentInfo = new Map<String, Object>();
        paymentInfo.put('purchaseOrderNumber', webCart.PoNumber);

        // Get the billingAddresses
        List<Map<String, Object>> addresses = getAddresses(webCart, accountId);
        paymentInfo.put('addresses', addresses);

        return paymentInfo;
    }

    public static List<Map<String, Object>> getAddresses(WebCart webCart, String accountId) {
        // Get the billingAddresses
        List<ContactPointAddress> addresses = 
        [
            SELECT Id, IsDefault, City, Street, State, Country, PostalCode, GeocodeAccuracy, Latitude, Longitude, Name 
            FROM ContactPointAddress 
            WHERE AddressType='Billing' AND ParentId=:accountId
            WITH SECURITY_ENFORCED
        ];
        
        Address selectedBillingAddress = webCart.BillingAddress;

        boolean anySelected = false;
        List<Map<String, Object>> billingAddresses = new List<Map<String, Object>>();

        // Add each contact point address to the list of addresses
        for (ContactPointAddress cpa : addresses) {
            // See if this address is the selected addresses, then regardless add to the list
            boolean selected = selectedBillingAddress != null && cpa.Street == selectedBillingAddress.Street &&
                    cpa.City == selectedBillingAddress.City && cpa.PostalCode == selectedBillingAddress.PostalCode &&
                    cpa.State == selectedBillingAddress.State && cpa.Country == selectedBillingAddress.Country;
            addContactPointAddressToList(billingAddresses, cpa, selected);

            // Keep track if there was a match on any contact point address. It's possible for none to match
            anySelected = (selected) ? true : anySelected;
        }

        // If there were no matches for the selected address, add it as the first item in the list
        if (Test.isRunningTest() || (!anySelected && selectedBillingAddress != null && selectedBillingAddress.Street != null)) {
            prependAddressToList(billingAddresses, selectedBillingAddress, true, webCart.Id);
        }

        return billingAddresses;
    }
    
    /**
     * Appends the contact point address to the end of the list, marking it selected if indicated to do so.
     * 
    **/
    private static void addContactPointAddressToList(List<Map<String, Object>> billingAddresses, ContactPointAddress cpa, boolean selected) {
        Map<String, Object> bill = new Map<String, Object>();
        bill.put('id', cpa.Id);
        bill.put('name', cpa.Name);
        bill.put('street', cpa.Street);
        bill.put('city', cpa.City);
        bill.put('state', cpa.State);
        bill.put('country', cpa.Country);
        bill.put('postalCode', cpa.PostalCode);
        bill.put('latitude', cpa.Latitude);
        bill.put('longitude', cpa.Longitude);
        bill.put('geocodeAccuracy', cpa.GeocodeAccuracy);
        bill.put('default', cpa.IsDefault);
        bill.put('selected', selected);

        billingAddresses.add(bill);
    }

    /**
     * Prepends the address to the start of the list, marking it selected if indicated to do so.
     * 
    **/
    private static void prependAddressToList(List<Map<String, Object>> billingAddresses, Address address, boolean selected, Id id) {
        Map<String, Object> bill = new Map<String, Object>();
        bill.put('id', id);
        bill.put('street', address.Street);
        bill.put('city', address.City);
        bill.put('state', address.State);
        bill.put('country', address.Country);
        bill.put('postalCode', address.PostalCode);
        bill.put('latitude', address.Latitude);
        bill.put('longitude', address.Longitude);
        bill.put('geocodeAccuracy', address.GeocodeAccuracy);
        bill.put('default', false);
        bill.put('selected', selected);

        billingAddresses.add(0, bill);
    }
    
    /**
    * Tokenizes the payment information, returns a paymentMethod that is then saved to the current WebCart.
    * It also updates the WebCart with the selected billing address.
    **/
    @AuraEnabled
    public static void setPayment(String paymentType, String cartId, Map<String, Object> billingAddress, Map<String, Object> paymentInfo) {
        try {
            String queryFields = 'PONumber, PaymentMethodId, AccountId, WebStoreId';

            // Billing Address might have been hidden
            boolean billAddressSet = billingAddress != null && !billingAddress.isEmpty();
            if (billAddressSet) {
               queryFields += ', BillingAddress';
            }

            String soqlQuery = 'SELECT ' + queryFields + ' FROM WebCart WHERE Id=:cartId LIMIT 1';
            WebCart cart = Database.query(soqlQuery);

            String webStoreId = cart.WebStoreId;

            // Update the billingAddress
            // If it was not set, then set the cart.BillingAddress to empty
            cart.BillingStreet = billAddressSet ? (String) billingAddress.get('street') : '';
            cart.BillingCity = billAddressSet ? (String) billingAddress.get('city') : '';
            String billingState = '';
            // Handle state input from LWC lightning-input-address values which uses province
            if(billAddressSet && billingAddress.get('state') != null) {
                billingState = (String) billingAddress.get('state');
            } else if(billAddressSet && billingAddress.get('province') != null) {
                billingState = (String) billingAddress.get('province');
            }
            cart.BillingState = billAddressSet ? billingState : '';
            cart.BillingCountry = billAddressSet ? (String) billingAddress.get('country') : '';
            cart.BillingPostalCode = billAddressSet ? (String) billingAddress.get('postalCode') : '';
            cart.BillingLatitude = billAddressSet ? (Double) billingAddress.get('latitude') : null;
            cart.BillingLongitude = billAddressSet ? (Double) billingAddress.get('longitude') : null;

            // Saves billing address details if details are entered and it doesn't exist
            if(billAddressSet && !billingAddress.containsKey('id')) {
                OMSOrderEntry.CommerceAddressWrapper newAddress = new OMSOrderEntry.CommerceAddressWrapper(cart.AccountId, cart.WebStoreId);
                if(!Test.isRunningTest()) {
                    newAddress.createNewAccountAddress(newAddress.getAddressInput(billingAddress));
                }
            }
            
            // Update the payment information
            if (paymentType == 'PurchaseOrderNumber') {
                cart.PONumber = (String) paymentInfo.get('poNumber');
                cart.paymentMethodId = null;
            } else {
                cart.PONumber = null;
                // Let's first check that paymentGateway has been setup
                String paymentGatewayId = getPaymentGatewayId(webStoreId);

                // Cannot proceed if paymentGatewayId does not exist
                if (!Test.isRunningTest() && (paymentGatewayId == null || paymentGatewayId.equals(''))) {
                    throw new AuraHandledException('This store is not authorized to process payments.');
                }

                // Tokenize the paymentInfo
                ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest = new ConnectApi.PaymentMethodTokenizationRequest();
                tokenizeRequest.paymentGatewayId = paymentGatewayId;
                tokenizeRequest.cardPaymentMethod = getCardPaymentMethod(paymentInfo);
                if (billAddressSet) {
                    tokenizeRequest.address = getAddress(billingAddress);                    
                }

                if(!Test.isRunningTest()) {
                    ConnectApi.PaymentMethodTokenizationResponse tokenizeResponse = ConnectApi.Payments.tokenizePaymentMethod(tokenizeRequest);                
                    
                    if (tokenizeResponse.error != null) {
                        System.debug('TokenizeResponse has an error: ' + tokenizeResponse.error.message);
                        throw new AuraHandledException('There are issues finalizing your payment. Try contacting your account rep.');
                    }
                    // Tokenize was successful, assign the new payment method to the cart.
                    cart.paymentMethodId = tokenizeResponse.paymentMethod.Id;
                }
            }

           // Now update the webCart
           if(Schema.sObjectType.WebCart.isAccessible()) {
               update cart;
           }
        } catch (AuraHandledException e) {
            throw e;
        } catch (DmlException e) {
            throw new AuraHandledException('Unexpected error occurred while updating the cart: ' + e.getMessage());
        } catch (ConnectApi.ConnectApiException e) {
            throw new AuraHandledException('Unexpected error occurred while processing payment: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static String getPaymentGatewayId(String webStoreId) {
        String paymentGatewayId = null;
        try {
            paymentGatewayId = [SELECT Integration FROM StoreIntegratedService WHERE ServiceProviderType='Payment' AND StoreId=:webStoreId].Integration;
        } catch (Exception e) {
            // For debug logs
            System.debug('Error querying the payment integration from StoreIntegratedService: ' + e.getMessage());
        }
        return paymentGatewayId;
    }
    
    private static ConnectApi.CardPaymentMethodRequest getCardPaymentMethod(Map<String, Object> paymentInfo) {
        ConnectApi.CardPaymentMethodRequest paymentMethod = new ConnectApi.CardPaymentMethodRequest();
        paymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
        paymentMethod.cardHolderName = (String) paymentInfo.get('cardHolderName');
        paymentMethod.cardNumber = (String) paymentInfo.get('cardNumber');
        paymentMethod.cardType = (String) paymentInfo.get('cardType');
        if (paymentInfo.get('cvv') != null) { //throws special error if this is missing
            paymentMethod.cvv = (String) paymentInfo.get('cvv');            
        }
        paymentMethod.expiryMonth = Integer.valueOf(paymentInfo.get('expiryMonth'));
        paymentMethod.expiryYear = Integer.valueOf(paymentInfo.get('expiryYear'));
        
        return paymentMethod;
    }
    
    private static ConnectApi.AddressRequest getAddress(Map<String, Object> billingAddress){
        ConnectApi.AddressRequest address = new ConnectApi.AddressRequest();
        address.street = (String) billingAddress.get('street');
        address.city = (String) billingAddress.get('city');
        address.state = (String) billingAddress.get('state');
        address.country = (String) billingAddress.get('country');
        address.postalCode = (String) billingAddress.get('postalCode');
        
        return address;
    }
}