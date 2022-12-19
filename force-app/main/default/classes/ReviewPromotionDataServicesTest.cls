@isTest
public class ReviewPromotionDataServicesTest {

    @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        Promotion pm = new Promotion(Name='Test',StartDate=Date.today());
        insert pm;
        Coupon cpn = new Coupon(CouponCode='COUPONCODE',PromotionId=pm.Id,StartDateTime = Datetime.now(),EndDateTime=Datetime.now().addDays(2));
        insert cpn;
        
    }
    
     @isTest static void getCartItemsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id webCartId = [SELECT Id FROM WebCart LIMIT 1].Id;
        string productFieldsAPINames = 'Name,Family,ProductCode,Type,StockKeepingUnit,DisplayUrl';
        ReviewPromotionDataServices.getCartItems(webStoreId, accountId, webCartId, productFieldsAPINames );
        Test.stopTest();
        
    }
    
    @isTest static void getCouponsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id webCartId = [SELECT Id FROM WebCart LIMIT 1].Id;
     
        ReviewPromotionDataServices.getCoupons(webStoreId, accountId, webCartId);
        Test.stopTest();
        
    }
    
    
    @isTest static void applyCouponsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id webCartId = [SELECT Id FROM WebCart LIMIT 1].Id;
      
        ReviewPromotionDataServices.applyCoupons(webStoreId, accountId, webCartId,'COUPONCODE');
        Test.stopTest();
        
    }
    @isTest static void deleteCouponsTest(){
        
        Test.startTest();
        Id webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id ;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id webCartId = [SELECT Id FROM WebCart LIMIT 1].Id;
        Id CouponId = [SELECT Id FROM Coupon  LIMIT 1].Id;
      
        ReviewPromotionDataServices.deleteCoupons(webStoreId, accountId, webCartId,CouponId);
        Test.stopTest();
        
    }
 
 
    
    
    
    
    
}