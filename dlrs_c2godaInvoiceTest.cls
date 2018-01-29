/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_c2godaInvoiceTest
{
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {
        // Force the dlrs_c2godaInvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new c2g__codaInvoice__c());
    }
}