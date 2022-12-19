@isTest
public class OrderEntryUtilityClassesTest {
	 @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, IsSecondary=true);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(CartId=cart.Id, Sku='SKU_Test1', SalesPrice=10.00, Quantity=3.0, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
    }
    
    @isTest static void HeaderContainerDataServiceTest(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<HeaderContainerDataService.HeaderContainerFlowInputs> flowInputs = new List<HeaderContainerDataService.HeaderContainerFlowInputs>();
        HeaderContainerDataService.HeaderContainerFlowInputs flowInput = new HeaderContainerDataService.HeaderContainerFlowInputs();
        flowInput.recordId = accountId;
        flowInputs.add(flowInput);
        
        HeaderContainerDataService.getContextData(flowInputs);
    }
    
    @isTest static void FieldLabelDataServicesTest(){
        List<FieldLabelDataServices.HeaderContainerFlowInputs> flowInputs = new List<FieldLabelDataServices.HeaderContainerFlowInputs>();
		FieldLabelDataServices.HeaderContainerFlowInputs flowInput = new FieldLabelDataServices.HeaderContainerFlowInputs();
        flowInput.fieldAPI = 'Name,ProductCode';
        flowInputs.add(flowInput);
		FieldLabelDataServices.getFieldLabel(flowInputs);
    }
    
    @isTest static void ActiveCartFetchDataServiceTest(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<ActiveCartFetchDataService.FlowInput> inputList = new List<ActiveCartFetchDataService.FlowInput>();
        ActiveCartFetchDataService.FlowInput t = new ActiveCartFetchDataService.FlowInput();
        
        t.recordId = accountId;
        
        inputList.add(t);
        ActiveCartFetchDataService.getActiveCard(inputList);
    }
    
}