/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 12-08-2022
 * @last modified by  : Ajitesh
**/
public with sharing class ActiveCartFetchDataService {
    
    public class FlowInput{
        @InvocableVariable public Id recordId;
    }

    public class FlowOutput{
        @InvocableVariable public Id cartId;
    }

    
    /**
    * @description get Active cards for current user
    * @author Ajitesh | 10-18-2022 
    * @param recordInfo 
    * @return List<FlowOutput> 
    **/
    @InvocableMethod(label='Get Active Cart')
    public static List<FlowOutput> getActiveCard(List<FlowInput> recordInfo){
        try{
            WebCart cartRec = [SELECT Id FROM WebCart WHERE (Status='Active' OR Status='Checkout') AND AccountId=: recordInfo[0].recordId AND IsSecondary=true];
            FlowOutput flowOutputVar = new FlowOutput();
            flowOutputVar.cartId = cartRec.Id;
            return new List<FlowOutput>{flowOutputVar};
        }
        catch(Exception e){
            return new List<FlowOutput>();
        }
    }


}