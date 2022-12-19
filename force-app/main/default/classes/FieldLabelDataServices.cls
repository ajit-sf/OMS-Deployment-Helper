/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 10-06-2022
 * @last modified by  : Ajitesh
**/
public with sharing class FieldLabelDataServices {

    public final static String OBJECT_NAME = 'Product2';

     // Flow Helper wrapper variable
    public class HeaderContainerFlowInputs{
        @InvocableVariable public String fieldAPI;
    }

    public class HeaderContainerFlowOutputs{
        @InvocableVariable public String fieldLabel;
    }
    // Flow Helper wrapper variable
    
    /**
    * @description Get field labels from the passed fields API's
    * @author Ajitesh | 10-06-2022 
    * @param flowInputs 
    * @return HeaderContainerFlowOutputs[] 
    **/
    @InvocableMethod(label='Get Field Label')
    public static HeaderContainerFlowOutputs[] getFieldLabel(List<HeaderContainerFlowInputs> flowInputs){
        List<HeaderContainerFlowOutputs> headerHelper = new List<HeaderContainerFlowOutputs>();
        HeaderContainerFlowOutputs flowOutput = new HeaderContainerFlowOutputs();
        String fieldLabel = '';
        
        String objectName = OBJECT_NAME;

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();

        for(String tempAPI : flowInputs[0].fieldAPI.split(',')){
            fieldLabel += fieldMap.get(tempAPI).getDescribe().getLabel() + ',';
        }

        flowOutput.fieldLabel = fieldLabel;
        headerHelper.add(flowOutput);
        return headerHelper;
    }

}