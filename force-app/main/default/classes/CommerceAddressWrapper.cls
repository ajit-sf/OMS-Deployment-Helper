public with sharing class CommerceAddressWrapper {
    private static final String SHIPPING_TYPE = 'Shipping';
    private static final String BILLING_TYPE = 'Billing';

    private static String accountId;
    private static String webStoreId;
    private static Boolean defaultAddressOnly;
    private static ConnectApi.CommerceAddressCollection accountAddresses;

    public CommerceAddressWrapper(String accId, String storeId) {
        accountId = accId;
        webStoreId = storeId;
        defaultAddressOnly = false;
        if(!Test.isRunningTest()) {
            accountAddresses = ConnectApi.CommerceBuyerExperience.getCommerceAccountAddress(webStoreId, accountId, defaultAddressOnly);
        }
    }

  /*  public CommerceAddressWrapper(String accId, String storeId, Boolean defaultOnly) {
        accountId = accId;
        webStoreId = storeId;
        defaultAddressOnly = defaultOnly;
        if(!Test.isRunningTest()) {
            accountAddresses = ConnectApi.CommerceBuyerExperience.getCommerceAccountAddress(webStoreId, accountId, defaultAddressOnly);
        }
    } 

    public String getAccountId() {
        return accountId;
    }

    public String getWebStoreId() {
        return webStoreId;
    } */

    public List<ConnectApi.CommerceAddressOutput> getShippingAddresses() {
        return getAddresses(SHIPPING_TYPE);
    }

    public List<ConnectApi.CommerceAddressOutput> getBillingAddresses() {
        return getAddresses(BILLING_TYPE);
    }

    public ConnectApi.CommerceAddressOutput createNewAccountAddress(ConnectApi.commerceAddressInput addressInput) {
        return ConnectApi.CommerceBuyerExperience.createCommerceAccountAddress(webStoreId, accountId, addressInput);
    }

    public String deleteAccountAddress(String addressId) {
        try {
            ConnectApi.CommerceBuyerExperience.deleteCommerceAccountAddress(webstoreId, accountId, addressId);
            return 'Deleted';
        } catch(Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    public ConnectApi.commerceAddressInput getAddressInput(Map<String,Object> addressDetails) {
        ConnectApi.commerceAddressInput addressInput = new ConnectApi.commerceAddressInput();
        addressInput.name = (String)addressDetails.get('name');
        addressInput.street = (String)addressDetails.get('street');
        addressInput.city = (String)addressDetails.get('city');
        if(addressDetails.get('region') == null) {
            addressInput.region = (String)addressDetails.get('province');
        } else {
            addressInput.region = (String)addressDetails.get('region');
        }
        addressInput.postalCode = (String)addressDetails.get('postalCode');
        addressInput.country = (String)addressDetails.get('country');
        addressInput.addressType = (String)addressDetails.get('addressType');
        addressInput.isDefault = addressDetails.containsKey('isDefault') ? (Boolean)addressDetails.get('isDefault') : false;

        return addressInput;
    }

    private static List<ConnectApi.CommerceAddressOutput> getAddresses(String addressType) {
        List<ConnectApi.CommerceAddressOutput> addresses = new List<ConnectApi.CommerceAddressOutput>();
        if(!Test.isRunningTest()) {
            for(ConnectApi.CommerceAddressOutput addressOutput : accountAddresses.items) {
                System.debug('Address Type = ' + addressOutput.addressType);
                if(addressOutput.addressType.equals(addressType)) {
                    addresses.add(addressOutput);
                }
            }
        }
        return addresses;
    }
}