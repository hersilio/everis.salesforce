@isTest
public class AccountTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>{
            new Account(Name = 'Teste 1', Type = 'CPF', AccountNumber = '11111111111'),
            new Account(Name = 'Teste 1', Type = 'CNPJ', AccountNumber = '11111111111111')
        };

        insert accList;
        
        Task task1 = new Task(Subject = 'Consumidor Final', Status = 'Not Started', Priority = 'Normal');

        insert task1;

        Opportunity opp1 = new Opportunity(Name = 'Teste 1 - opp Parceiro', CloseDate = Date.today().addDays(30), StageName = 'Qualification');

        insert opp1;
    }

    @isTest
    static void TestUpdateCpf(){

        Account acc = getAccountCpf();

        String newAccountNumber = '22222222222';

        acc.AccountNumber = newAccountNumber;

        update acc;

        System.assert(acc.AccountNumber == newAccountNumber);        
    }

    @isTest
    static void TestUpdateCnpj(){

        Account acc = getAccountCnpj();

        String newAccountNumber = '22222222222222';

        acc.AccountNumber = newAccountNumber;

        update acc;

        System.assert(acc.AccountNumber == newAccountNumber);        
    }

    @isTest
    static void TestUpdateInvlidCpf(){

        Account acc = getAccountCpf();

        String newAccountNumber = '222222222222';

        try {            

            acc.AccountNumber = newAccountNumber;

            update acc;

        } catch (Exception ex) {            
        }

        System.assert(getAccountCpf().AccountNumber != newAccountNumber);
    }

    @isTest
    static void TestUpdateInvlidCnpj(){

        Account acc = getAccountCnpj();

        String newAccountNumber = '2222222222222222';

        try {            

            acc.AccountNumber = newAccountNumber;

            update acc;

        } catch (Exception ex) {            
        }

        System.assert(getAccountCpf().AccountNumber != newAccountNumber);
    }

    @isTest
    static void InsertPartnerAccount(){
        Account acc = new Account(Name = 'Teste Partner', Type = 'Partner');

        insert acc;

        Opportunity opp = getOpportunityFromAccountId(acc.Id);

        System.assert(opp.StageName == 'Qualification');
    }

    @isTest
    static void InsertCustomer(){
        Account acc = new Account(Name = 'Teste Partner', Type = 'Customer');

        insert acc;

        Task task = getTaskFromAccountId(acc.Id);

        System.assert(task.Status == 'Not Started' && task.Priority == 'Normal');
    }

    @isTest
    static void TestInsertBulk(){
        
        List<Account> accountToInsert = new list<Account>();
        
        try{
            
            for (Integer i = 1; i <= 500; i++){
                Account acc = new Account(Name='Test Bulk ' + i, Type = 'CPF', AccountNumber = '11111111111');
    
                accountToInsert.add(acc);
            }
            
            insert accountToInsert;
        }
        catch (Exception ex){
        }

        List<Account>  accountInsertedList = [SELECT Id
            FROM Account 
            WHERE Name like 'Test Bulk%'];
            
        System.assertEquals(accountToInsert.size(), accountInsertedList.size());
    }

    private static Account getAccountCpf(){
        List<Account> accList = [Select Id, AccountNumber From Account where Type = 'CPF' limit 1];

        return !accList.isEmpty() ? accList[0] : new Account();
    }

    private static Account getAccountCnpj(){
        List<Account> accList = [Select Id, AccountNumber From Account where Type = 'CNPJ' limit 1];

        return !accList.isEmpty() ? accList[0] : new Account();
    }

    private static Task getTaskFromAccountId(Id accId){
        List<Task> taskList = [Select Id, Subject, Status, Priority From Task where WhatId =: accId limit 1];

        return !taskList.isEmpty() ? taskList[0] : new Task();
    }

    private static Opportunity getOpportunityFromAccountId(Id accId){
        List<Opportunity> oppList = [Select Id, StageName From Opportunity where AccountId =: accId limit 1];

        return !oppList.isEmpty() ? oppList[0] : new Opportunity();
    }
}
