/**
    Author:         Derrick Vuong
    Company:        Salesforce
    Description:    ShippingAddressController.cls
    Date:           26-Sep-2022

    TODO:
    - 
**/

public with sharing class ShippingAddressController {
    /**
     * createAccountAddress
     * @desc Creates a new shipping address for the Account
     * 
     * @param {String} accountOrRelatedId The Account or Contact Id
     * @param {String} storeOrNetworkId The Network or WebStore Id
     * @param {String} addressDetails A JSON string of the address details used to form the ConnectApi.commerceAddressInput
     * 
     * @return {ConnectApi.CommerceAddressOutput} The new address details that is created
     */
    @AuraEnabled
    public static String createAccountAddress(String accountOrRelatedId, String storeOrNetworkId, Map<String, Object> addressDetails) {
        String accountId = OMSOrderEntry.Utility.resolveAccountId(accountOrRelatedId);
        String webStoreId = OMSOrderEntry.Utility.resolveStoreId(storeOrNetworkId);
        OMSOrderEntry.CommerceAddressWrapper commerceAddress = new OMSOrderEntry.CommerceAddressWrapper(accountId, webStoreId);
        ConnectApi.commerceAddressInput addressInput = commerceAddress.getAddressInput(addressDetails);
        return commerceAddress.createNewAccountAddress(addressInput).addressId;
    }


    /**
     * deleteAccountAddress
     */
    @AuraEnabled
    public static String deleteAccountAddress(String accountOrRelatedId, String storeOrNetworkId, String addressId) {
        String accountId = OMSOrderEntry.Utility.resolveAccountId(accountOrRelatedId);
        String webStoreId = OMSOrderEntry.Utility.resolveStoreId(storeOrNetworkId);
        OMSOrderEntry.CommerceAddressWrapper commerceAddress = new OMSOrderEntry.CommerceAddressWrapper(accountId, webStoreId);
        return commerceAddress.deleteAccountAddress(addressId);
    }


    /**
     * getAccountAddresses
     * @desc Gets the shipping addresses saved for the Account
     * 
     * @param {String} accountOrRelatedId The Account or Contact Id
     * @param {String} storeOrNetworkId The Network or WebStore Id
     * 
     * @return {List<ConnectApi.CommerceAddressOutput>} Result of shipping address items from ConnectApi.CommerceBuyerExperience.getCommerceAccountAddress
     */
    @AuraEnabled(cacheable=true)
    public static List<ConnectApi.CommerceAddressOutput> getAccountAddresses(String accountOrRelatedId, String storeOrNetworkId) {
        String accountId = OMSOrderEntry.Utility.resolveAccountId(accountOrRelatedId);
        String webStoreId = OMSOrderEntry.Utility.resolveStoreId(storeOrNetworkId);
        Boolean defaultOnly = false;
        OMSOrderEntry.CommerceAddressWrapper commerceAddress = new OMSOrderEntry.CommerceAddressWrapper(accountId, webStoreId);

        return commerceAddress.getShippingAddresses();
    }
}