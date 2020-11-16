public without sharing class AccountTriggerHandler extends TriggerHandler{
   List<Account> accountList;
   Map<Id, Account> oldAccMap; 

   public AccountTriggerHandler(){
      this.oldAccMap  = (Map<Id, Account>)Trigger.oldMap; 
      this.accountList = (List<Account>)Trigger.New; 
   }

   public override void beforeUpdate() {
      VerifyValidAccountNumber();
   }

   public override void beforeInsert() {
      VerifyValidAccountNumber();
   }

   public override void afterUpdate() {
      VerifyAccountType();      
   }

   public override void afterInsert() {
      VerifyAccountType();      
   }

   private void VerifyValidAccountNumber(){

      for(Account acc : this.accountList){

         Account accOld = this.oldAccMap != null ? this.oldAccMap.get(acc.Id) : null;

         if(accOld == null || accOld.AccountNumber != acc.AccountNumber || accOld.Type  != acc.Type){
            switch on acc.Type {
               when 'CPF' {
                  if(!Utils.ValidCpf(acc.AccountNumber)){
                     acc.addError('Número do cliente é inválido.');
                     return;
                  }
               }
               when 'CNPJ' {
                  if(!Utils.ValidCnpj(acc.AccountNumber)){
                     acc.addError('Número do cliente é inválido.');
                     return;
                  }
               }
            }

            acc.AccountNumber = acc.Type == 'CNPJ' || acc.Type == 'CPF' ? Utils.RemoveCharacters(acc.AccountNumber) : acc.AccountNumber;
         }         
      }
   }

   private void VerifyAccountType(){

      // obter oportunidades para verificar se já foi criado para conta
      List<Opportunity> oppList = [Select Id, AccountId From Opportunity Where StageName = 'Qualification'];
      Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();

      for(Opportunity opp : oppList){
         oppMap.put(opp.AccountId, opp);
      }

      // obter tarefas para verificar se já foi criado para a conta
      List<Task> taskList = [Select Id, WhatId From Task Where Status = 'Not Started'];
      Map<Id, Task> taskMap = new Map<Id, Task>();

      for(Task task : taskList){
         taskMap.put(task.WhatId, task);
      }
      
      List<Task> taskListToInsert = new List<Task>();
      List<Opportunity> opportunityListToInsert = new List<Opportunity>();      

      for(Account acc : this.accountList){
         switch on acc.Type {
            when 'Partner'{
               Opportunity opp = oppMap.get(acc.Id);

               if(opp == null){
                  opp = new Opportunity(
                     Name = acc.Name + ' - opp Parceiro', 
                     CloseDate = Date.today().addDays(30), 
                     StageName = 'Qualification',
                     AccountId = acc.Id
                  );

                  opportunityListToInsert.add(opp);
               }
            }
            when 'Customer' {
               Task task = taskMap.get(acc.Id);

               if(task == null){
                  task = new Task(
                     Subject = 'Consumidor Final', 
                     WhatId = acc.Id, 
                     Status = 'Not Started', 
                     Priority = 'Normal'
                  );

                  taskListToInsert.add(task);
               }
            }
         }
      }

      if(!taskListToInsert.isEmpty()){
         insert taskListToInsert;
      }

      if(!opportunityListToInsert.isEmpty()){
         insert opportunityListToInsert;
      }
   }
}