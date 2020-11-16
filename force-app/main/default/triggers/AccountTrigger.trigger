trigger AccountTrigger on Account (before update, after update, before insert, after insert) {
    new AccountTriggerHandler().run();
}