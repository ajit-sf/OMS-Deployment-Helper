public with sharing class BillingAddressController {
    /**
     * @name getAccountAddresses
     * @desc Gets the shipping addresses saved for the Account
     * 
     * @param {String} accountOrRelatedId The Account or Contact Id
     * @param {String} storeOrNetworkId The Network or WebStore Id
     * 
     * @return {List<ConnectApi.CommerceAddressOutput>} Result of billing address items from ConnectApi.CommerceBuyerExperience.getCommerceAccountAddress
     */
    @AuraEnabled(cacheable=true)
    public static List<ConnectApi.CommerceAddressOutput> getAccountAddresses(String accountOrRelatedId, String storeOrNetworkId) {
        String accountId = OMSOrderEntry.Utility.resolveAccountId(accountOrRelatedId);
        String webStoreId = OMSOrderEntry.Utility.resolveStoreId(storeOrNetworkId);
        OMSOrderEntry.CommerceAddressWrapper commerceAddress = new OMSOrderEntry.CommerceAddressWrapper(accountId, webStoreId);

        return commerceAddress.getBillingAddresses();
    }
}