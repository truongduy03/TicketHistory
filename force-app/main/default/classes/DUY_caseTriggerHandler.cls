public with sharing class DUY_caseTriggerHandler {
    public static void onAfterUpdate(List<Case> newCases, Map<Id,Case> oldMap) {
        handleUpdateTicketHistory(newCases, oldMap);
    }
    public static void onAfterInsert(List<Case> newCases) {
        // code Submit Status -->
        List<Id> caseIds = new List<Id>();
        for (Case cs : newCases) {
            caseIds.add(cs.Id);
        }
        updateSubmitStatusAsync(caseIds);
        // <--
    }

    private static void handleUpdateTicketHistory(List<Case> newCases, Map<Id,Case> oldMap){
        List<VMO_TicketHistory__c> ticketHandlers = new List<VMO_TicketHistory__c>();
        List<Case> casesToUpdate = new List<Case>();
        List<String> all = new List<String>();
        for(Case newCase : newCases){
            if(newCase.VMO_TicketHandler__c != oldMap.get(newCase.id).VMO_TicketHandler__c){
                all.add(oldMap.get(newCase.id).VMO_TicketHandler__c);
                all.add(newCase.VMO_TicketHandler__c);
            }
        }
        List<User> users = [SELECT Id, Name From User WHERE Id IN :all];
        for(Case newCase : newCases){
            Case aloCase = oldMap.get(newCase.Id);
            if(newCase.Status != oldMap.get(newCase.id).Status){
                createTicketHistoryRecord(ticketHandlers, newCase, oldMap, 'Status', newCase.Status, oldMap.get(newCase.id).Status);
            }
            if(newCase.OwnerId != oldMap.get(newCase.id).OwnerId){
                createTicketHistoryRecord(ticketHandlers, newCase, oldMap, 'Owner Id', newCase.OwnerId, oldMap.get(newCase.id).OwnerId);
            }
            if(newCase.VMO_Answer__c != oldMap.get(newCase.id).VMO_Answer__c){
                createTicketHistoryRecord(ticketHandlers, newCase, oldMap, 'Answer', newCase.VMO_Answer__c, oldMap.get(newCase.id).VMO_Answer__c);
            }
            Map<Id,User> userMap = new Map<Id, User>();
            for(User u : users){
                userMap.put(u.Id, u);
            }
            if(newCase != null && oldMap != null){
                if(newCase.VMO_TicketHandler__c != oldMap.get(newCase.id).VMO_TicketHandler__c){
                    User newTicketHandler = userMap.get(newCase.VMO_TicketHandler__c);
                    User oldTicketHandler = userMap.get(oldMap.get(newCase.id).VMO_TicketHandler__c);
                    createTicketHistoryRecord(ticketHandlers, newCase, oldMap, 'Ticket Handler', newTicketHandler?.Name, oldTicketHandler?.Name);
                }
            }
        }
        insert ticketHandlers;
    }
    private static void createTicketHistoryRecord(
        List<VMO_TicketHistory__c> ticketHandlers,
        Case currentCase,
        Map<Id,Case> oldMap,
        String fieldName,
        String newValue,
        String oldValue
    ){
        VMO_TicketHistory__c ticketHistory = new VMO_TicketHistory__c();
        ticketHistory.VMO_FieldName__c = fieldName;
        ticketHistory.VMO_NewValue__c = String.valueOf(newValue);
        ticketHistory.VMO_OldValue__c= String.valueOf(oldValue);
        ticketHistory.VMO_ChangedTime__c = DateTime.now();
        ticketHistory.VMO_RelatedTicket__c = currentCase.Id;
        ticketHistory.VMO_ChangedUser__c = currentCase.LastModifiedById;
        ticketHandlers.add(ticketHistory);
    }

    // code Submit Status -->
    @future
    public static void updateSubmitStatusAsync(List<Id> caseIds) {
        List<Case> casesToUpdate = new List<Case>();
        DateTime startOfDay = DateTime.now().date();
        List<Case> queriedCases = [SELECT Id, SubmitSts__c, CreatedDate FROM Case WHERE Id IN :caseIds AND CreatedDate >= :startOfDay];

        for (Case cs : queriedCases) {
            if (cs.SubmitSts__c == 'New') {
                cs.SubmitSts__c = 'Submitted';
                casesToUpdate.add(cs);
            }
        }
            update casesToUpdate;
    }
    // <--
}