/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 11-22-2022
 * @last modified by  : Ajitesh
**/
public with sharing class ReviewPromotionDataServices {
    
    /**
    * @description getting cart item created
    * @author Ajitesh | 10-06-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param activeCartOrId 
    * @return string 
    **/
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(Id webstoreId, Id effectiveAccountId, Id activeCartOrId, String productFieldsAPI){
        try {
            String productFieldAPIOnlyFive = '';
            String pageParam = null;
            Integer pageSize = null;
            for(Integer i = 0; i < productFieldsAPI.split(',').size(); i++){
                if(i>4){
                    break;
                }
                productFieldAPIOnlyFive += productFieldsAPI.split(',')[i] + ',';
            }
            productFieldAPIOnlyFive = productFieldAPIOnlyFive.substring(0, productFieldAPIOnlyFive.length()-1);
            if (!Test.isRunningTest())return ConnectApi.CommerceCart.getCartItems(webstoreId, effectiveAccountId, activeCartOrId, productFieldAPIOnlyFive, pageParam, pageSize, null);
            
            return null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description getting cart coupons
    * @author Ajitesh | 10-06-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param activeCartOrId 
    * @return ConnectApi.CartCouponCollection 
    **/
    @AuraEnabled
    public static ConnectApi.CartCouponCollection getCoupons(Id webstoreId, Id effectiveAccountId, Id activeCartOrId){
        try {
            if (!Test.isRunningTest())return ConnectApi.CommerceCart.getCartCoupons(webstoreId, effectiveAccountId, activeCartOrId);
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     /**
    * @description apply cart coupons
    * @author Ajitesh | 10-06-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param activeCartOrId 
    * @return ConnectApi.CartCouponCollection 
    **/
    @AuraEnabled
    public static ConnectApi.CartCouponCollection applyCoupons(Id webstoreId, Id effectiveAccountId, Id activeCartOrId, String cartCouponCode){
        try{
            ConnectApi.cartCouponInput cp = new ConnectApi.cartCouponInput();
            cp.couponCode = cartCouponCode;
            if (!Test.isRunningTest())return ConnectApi.CommerceCart.applyCartCoupon(webstoreId, effectiveAccountId, activeCartOrId, cp);
            return null;            
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }


     /**
    * @description delete cart coupons
    * @author Ajitesh | 10-06-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param activeCartOrId 
    * @return ConnectApi.CartCouponCollection 
    **/
    @AuraEnabled
    public static void deleteCoupons(Id webstoreId, Id effectiveAccountId, Id activeCartOrId, Id cartCouponId){
        try{
           if (!Test.isRunningTest())ConnectApi.CommerceCart.deleteCartCoupon(webstoreId, effectiveAccountId, activeCartOrId, cartCouponId);            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}