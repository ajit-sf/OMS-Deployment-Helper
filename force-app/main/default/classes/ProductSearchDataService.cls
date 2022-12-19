/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 12-08-2022
 * @last modified by  : Ajitesh
**/
public with sharing class ProductSearchDataService {

    /**
    * @description Getting product suggestion for lookup based on search text
    * @author Ajitesh | 09-21-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param searchTerm 
    * @param maxResults 
    * @return string 
    **/
    @AuraEnabled
    public static ConnectApi.ProductSearchResults getProductSuggestion(String webstoreId, String effectiveAccountId, String searchTerm, String searchResultFields){
        try {
            ConnectApi.ProductSearchInput productSearchInput;
            productSearchInput = getSearchInput(searchTerm, searchResultFields);
            if (!Test.isRunningTest())return ConnectApi.CommerceSearch.searchProducts(webstoreId, effectiveAccountId,  productSearchInput);
            

            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Ajitesh | 09-22-2022 
    * @param searchText 
    * @param searchResultFields 
    * @return ConnectApi.ProductSearchInput 
    **/
    public static ConnectApi.ProductSearchInput getSearchInput(String searchText, String searchResultFields) {
        ConnectApi.ProductSearchInput searchInput = new ConnectApi.ProductSearchInput();

        searchInput.fields = searchResultFields.split(',');
        searchInput.includePrices = true;
        searchInput.searchTerm = searchText;

        return searchInput;
    }

    /**
    * @description 
    * @author Ajitesh | 09-22-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param ids 
    * @param fields 
    * @return ConnectApi.ProductOverviewCollection 
    **/
    @AuraEnabled
    public static ConnectApi.ProductOverviewCollection getProducts(String webstoreId, String effectiveAccountId, List<String> ids, List<String> fields){
        try {
            if (!Test.isRunningTest()) return ConnectApi.CommerceCatalog.getProducts(webstoreId, effectiveAccountId, ids, null, fields, false, false);
            else 
                return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
    * @description 
    * @author Ajitesh | 09-29-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param productData 
    * @return Id 
    **/
    @AuraEnabled
    public static Id createCardAndAddItems(String webstoreId, String effectiveAccountId, String productDataStr, String cartId){
        try {

            List<NewItemWrapper> productData = new List<NewItemWrapper>();

            productData = (List<NewItemWrapper>) JSON.deserialize(productDataStr, List<NewItemWrapper>.class);

            if(cartId == null){
                ConnectApi.CartInput cardInput = new ConnectApi.CartInput();
                cardInput.effectiveAccountId = effectiveAccountId;
                cardInput.isSecondary = true;
                if (!Test.isRunningTest()){
                    ConnectApi.CartSummary cardSummary = ConnectApi.CommerceCart.createCart(webstoreId, cardInput);
                    cartId = cardSummary.cartId;
                }
               	 
                
            }
            
            List<ConnectApi.BatchInput> cartItems = new List<ConnectApi.BatchInput>();

            List<ConnectApi.CartItemInput> cartItemsToUpdate = new List<ConnectApi.CartItemInput>();

            for(NewItemWrapper itemWrap : productData){
                ConnectApi.CartItemInput cartInputParap = new ConnectApi.CartItemInput();
                cartInputParap.productId = itemWrap.productId;
                cartInputParap.quantity = String.valueOf(itemWrap.quantity);
                cartInputParap.type = ConnectApi.CartItemType.PRODUCT;
                if(itemWrap.cartItemId == null){
                    cartItems.add(new ConnectApi.BatchInput(cartInputParap));
                }
                else if (!Test.isRunningTest())ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, cartId, itemWrap.cartItemId, cartInputParap);
                
                
            }
            if(cartItems.size() > 0){
                ConnectApi.BatchResult[] batchResults = new ConnectApi.BatchResult[]{};
                if (!Test.isRunningTest()) batchResults = ConnectApi.CommerceCart.addItemsToCart(webstoreId, effectiveAccountId, cartId, cartItems);
                    // Iterate through each returned result.
                    for (ConnectApi.BatchResult batchResult : batchResults) {
                        if (!batchResult.isSuccess()) {
                            // Operation failed. Print errors.
                            System.debug('FAILURE');
                            System.debug(batchResult.getErrorMessage());
                        }
                    
                	}

            }
            
            return cartId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class NewItemWrapper{
        @AuraEnabled public Id productId;
        @AuraEnabled public Integer quantity;
        @AuraEnabled public Id cartItemId;
    }

    /**
    * @description 
    * @author Ajitesh | 09-29-2022 
    * @param cartId 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @return ConnectApi.CartItemCollection 
    **/
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCurrentCartItems(Id cartId, String webstoreId, String effectiveAccountId){
       if (!Test.isRunningTest()) return ConnectApi.CommerceCart.getCartItems(webstoreId, effectiveAccountId, cartId);
       else
          return null;
    }

    /**
    * @description Delete cart item
    * @author Ajitesh | 10-06-2022 
    * @param webstoreId 
    * @param effectiveAccountId 
    * @param activeCartOrId 
    * @param cartItemId 
    **/
    @AuraEnabled
    public static void deleteCartItemHelper(Id webstoreId, Id effectiveAccountId, Id activeCartOrId, Id cartItemId){
        try {
            if (!Test.isRunningTest()) ConnectApi.CommerceCart.deleteCartItem(webstoreId, effectiveAccountId, activeCartOrId, cartItemId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}