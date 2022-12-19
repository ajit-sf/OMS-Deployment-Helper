@isTest
public class ProductSearchDataServiceTest {
	@testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(CartId=cart.Id, Sku='SKU_Test1', SalesPrice=10.00, Quantity=3.0, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
        
        Product2 prod  = new Product2(Name='TestProduct2');
        insert prod;
    }
    
    @isTest static void getProductSuggestionTest(){
        
        Test.startTest();
        // Associate the callout with a mock response.
        
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        // Test: execute the integration for the test cart ID.
        ProductSearchDataService.getProductSuggestion(webStoreId, accountId, 'Test', 'Name,ProductCode' );
        Test.stopTest();
        
    }
    
     @isTest static void getSearchInputTest(){
        
        Test.startTest();
       
        string searchText = 'Genwatt';
        string searchResultFields = 'Name,ListPrice';
         
        ProductSearchDataService.getSearchInput(searchText, searchResultFields);
        Test.stopTest();
        
    } 
    
     @isTest static void createCardAndAddItemsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id FROM WebCart LIMIT 1].Id;
         Id prodId = [SELECT Id FROM Product2 LIMIT 1].Id;
         
        List<ProductSearchDataService.NewItemWrapper> productData = new List<ProductSearchDataService.NewItemWrapper>();
        ProductSearchDataService.NewItemWrapper product1 = new ProductSearchDataService.NewItemWrapper();
         product1.productId = prodId;
         product1.quantity = 3;
         productData.add(product1);
        string productDataStr = JSON.serialize(productData);
        ProductSearchDataService.createCardAndAddItems(webStoreId, accountId,productDataStr,cartId);
        ProductSearchDataService.createCardAndAddItems(webStoreId, accountId,productDataStr,null);
        Test.stopTest();
        
    } 
    
       @isTest static void getProductsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<string> ids = new List<string>();
        List<string> fields = new List<string>();
     
        ProductSearchDataService.getProducts(webStoreId,accountId,ids,fields);
        Test.stopTest();
        
    } 
    
     @isTest static void getCurrentCartItemsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id FROM WebCart LIMIT 1].Id;
     
        ProductSearchDataService.getCurrentCartItems(cartId, webStoreId,accountId);
        Test.stopTest();
        
    } 
    
     @isTest static void deleteCartItemHelperTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id FROM WebCart LIMIT 1].Id;
         Id cartItemId = [SELECT Id FROM CartItem LIMIT 1].Id;
     
        ProductSearchDataService.deleteCartItemHelper( webStoreId,accountId,cartId,cartItemId);
        Test.stopTest();
        
    } 
    
    
}