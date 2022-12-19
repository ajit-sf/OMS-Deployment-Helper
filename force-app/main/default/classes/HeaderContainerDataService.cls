/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 10-05-2022
 * @last modified by  : Ajitesh
**/
public with sharing class HeaderContainerDataService {

    // Flow Helper wrapper variable
    public class HeaderContainerFlowInputs{
        @InvocableVariable public String recordId;
    }

    public class HeaderContainerFlowOutputs{
        @InvocableVariable public String objectName;
        @InvocableVariable public String recordName;
    }
    // Flow Helper wrapper variable

    /**
    * @description Getting the current context object name and Name of record
    * @author Ajitesh | 09-20-2022 
    * @param recordId 
    * @return List<String> 
    **/
    @InvocableMethod(label='Get Context Info OMS Order Entry')
    public static HeaderContainerFlowOutputs[] getContextData(List<HeaderContainerFlowInputs> flowInputs){
        try {
            List<HeaderContainerFlowOutputs> headerHelper = new List<HeaderContainerFlowOutputs>();
            HeaderContainerFlowOutputs flowOutput = new HeaderContainerFlowOutputs();


            Id recordId = flowInputs[0].recordId;
            flowOutput.objectName = recordId.getSObjectType().getDescribe().getName();
            
            SObject contextObj = Database.query('SELECT Name FROM ' + flowOutput.objectName + ' WHERE Id=:recordId');
            flowOutput.recordName = (String)contextObj.get('Name');

            headerHelper.add(flowOutput);

            return headerHelper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}