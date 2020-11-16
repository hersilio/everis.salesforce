global without sharing class AccountBatch implements Database.Batchable<SObject> {

    private string query;

    global AccountBatch() {

        Date dateLastOpp = Date.today().addDays(-120);

        DateTime dt = DateTime.newInstance(dateLastOpp.year(), dateLastOpp.month(),dateLastOpp.day());

        query = 'Select Id From Account where Inactive__c = false ' +
                'and Id Not In (Select AccountId From Opportunity ' +
                           'where (StageName = \'Closed Won\' And CloseDate >= ' + dt.format('yyyy-MM-dd') + ') Or StageName Not In (\'Closed Won\', \'Closed Lost\'))';        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        try{
            
            System.debug('Account to verify: ' + scope);

            Set<Id> accId = new Set<Id>();

            for(Account acc : (List<Account>)scope)
            {
                accId.add(acc.Id);
            }

            DateTime dateLastTask = DateTime.now().addDays(-90);

            List<Task> taskList = [Select Id, WhatId From Task where WhatId in: accId And CreatedDate > : dateLastTask];

            Map<Id, Task> taskMap = new Map<Id, Task>();
            for(Task task : taskList){
                taskMap.put(task.WhatId, task);
            }

            List<Account> accToInactive = new List<Account>();

            for(Account acc : (List<Account>)scope){
                Task taskCreated = taskMap.get(acc.Id);

                if(taskCreated != null){
                    continue;
                }

                acc.Inactive__c = true;

                accToInactive.add(acc);
            }

            if(!accToInactive.isEmpty()){

                System.debug('Account to inactive: ' + accToInactive);

                update accToInactive;
            }

        } catch(Exception ex) {
            System.debug(ex);
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}
