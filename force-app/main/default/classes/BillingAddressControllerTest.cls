@isTest
public class BillingAddressControllerTest {
    @isTest(SeeAllData=true)
    static void getAccountAddressesTest() {
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Burlington Textiles Corp of America' LIMIT 1];
        WebStore store = [SELECT Id, Name FROM WebStore WHERE Name = 'B2C Store' LIMIT 1];
        List<ConnectApi.CommerceAddressOutput> addresses = OMSOrderEntry.BillingAddressController.getAccountAddresses(a.Id, store.Id);
        System.assertNotEquals(0, addresses.size());
        System.assertNotEquals('', addresses[0].Street);

        Account a2 = [SELECT Id, Name FROM Account WHERE Name = 'John Buyer' LIMIT 1];
        List<ConnectApi.CommerceAddressOutput> addresses2 = OMSOrderEntry.BillingAddressController.getAccountAddresses(a2.Id, store.Id);
        System.assertEquals(0, addresses2.size());
    }
}