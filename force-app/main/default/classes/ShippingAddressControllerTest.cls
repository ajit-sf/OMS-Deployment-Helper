@IsTest(seealldata=true)
public class ShippingAddressControllerTest {
    @IsTest
    static void createAccountAddressTest() {
        Contact c = [SELECT Id FROM Contact WHERE Name = 'John Buyer'];
        Id networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE Webstore.Name = 'B2C Store'].NetworkId;
        Map<String, Object> addressDetails = getTestAddress();

        String addressId = ShippingAddressController.createAccountAddress(c.Id, networkId, addressDetails);
        System.assertNotEquals(null, addressId, 'Address Id is not null');
    }

    @IsTest
    static void deleteAccountAddressTest() {
        Contact c = [SELECT Id, AccountId FROM Contact WHERE Name = 'John Buyer' LIMIT 1];
        Id networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE Webstore.Name = 'B2C Store' LIMIT 1].NetworkId;
        Id addressId = [SELECT Id FROM ContactPointAddress WHERE ParentId = :c.AccountId LIMIT 1].Id;

        String result = ShippingAddressController.deleteAccountAddress(c.Id, networkId, addressId);
        System.assertEquals('Deleted', result, 'Address has been deleted');
    }

    @IsTest
    static void getAccountAddressesTest() {
        // Contact c = [SELECT Id, AccountId FROM Contact WHERE Name = 'John Buyer' LIMIT 1];
        User u = [SELECT Id, ContactId FROM User WHERE Name = 'John Buyer' LIMIT 1];
        Id networkId = [SELECT NetworkId FROM WebStoreNetwork WHERE Webstore.Name = 'B2C Store' LIMIT 1].NetworkId;

        List<ConnectApi.CommerceAddressOutput> adminAddresses = ShippingAddressController.getAccountAddresses(null, networkId);
        System.assertEquals(0, adminAddresses.size(), 'No addresses retrieved for admin');

        System.runAs(u) {
            List<ConnectApi.CommerceAddressOutput> addresses = ShippingAddressController.getAccountAddresses(null, networkId);
            System.assertEquals(0, addresses.size(), 'No addresses retrieved because api calls skipped');
        }
    }

    private static Map<String, Object> getTestAddress() {
        Map<String, Object> shippingAddress = new Map<String, Object>();
        shippingAddress.put('name', 'Test Test');
        shippingAddress.put('street', '123 Test St');
        shippingAddress.put('city', 'Test City');
        shippingAddress.put('province', 'Test State');
        shippingAddress.put('postalCode', '012345');
        shippingAddress.put('country', 'Test Country');
        return shippingAddress;
    }
}