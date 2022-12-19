public with sharing class checkoutSessionWaitController {
    @AuraEnabled(cacheable=true)
    public static CartCheckoutSession getCheckoutSession(String checkoutSessionId){
        List<CartCheckoutSession> sessions = [SELECT Id, IsProcessing
                                             FROM CartCheckoutSession
                                             WHERE Id = :checkoutSessionId
                                             WITH SECURITY_ENFORCED];
        if(sessions.size() > 0) {
            return sessions[0];
        } else {
            return null;
        }
    }
}