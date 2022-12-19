/**
    Author:         Derrick Vuong
    Company:        Salesforce
    Description:    Utility.cls
    Date:           29-Sep-2022

    TODO:
    - 
**/

public with sharing class Utility {
    /**
     * @name resolveAccountId
     * @desc Finds the related Account Id of the Id given
     * 
     * @param {Id} accountOrContactId The Account or Contact Id to resolve
     * 
     * @return {Id} The resolved Account Id
     */
    public static Id resolveAccountId(Id recordId) {
        Id resolvedAccountId = recordId;
        if(recordId == null) {
            String userId = UserInfo.getUserId();
            User u = [SELECT ContactId FROM User WHERE Id = :userId WITH SECURITY_ENFORCED LIMIT 1];
            if(u?.ContactId != null) {
                resolvedAccountId = [SELECT AccountId FROM Contact WHERE Id = :u.ContactId WITH SECURITY_ENFORCED LIMIT 1].AccountId;
            } else {
                resolvedAccountId = null;
            }
        } else if(String.valueOf(recordId.getSObjectType()) == 'Contact') {
            resolvedAccountId = [SELECT AccountId FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1].AccountId;
        }
        return resolvedAccountId;
    }


    /**
     * @name resolveStoreId
     * @desc Finds the related WebStoreId of the Id given
     * 
     * @param {Id} networkOrStoreId The Network or WebStore Id to resolve
     * 
     * @return {Id} The resolved WebStore Id
     */
    public static Id resolveStoreId(Id recordId) {
        Id resolvedStoreId = recordId;
        if(recordId == null && Network.getNetworkId() != null) {
            recordId = Network.getNetworkId();
        }

        if(String.valueOf(recordId.getSObjectType()) == 'Network') {
            resolvedStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :recordId WITH SECURITY_ENFORCED LIMIT 1]?.WebStoreId;
        }
        
        return resolvedStoreId;
    }
}