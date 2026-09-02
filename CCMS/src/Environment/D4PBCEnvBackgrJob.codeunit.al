namespace D4P.CCMS.Environment;

using D4P.CCMS.Tenant;

codeunit 62028 "D4P BC Env Backgr. Job"
{
    TableNo = "D4P BC Tenant";

    trigger OnRun()
    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
    begin
        EnvironmentManagement.GetEnvironmentsAsBackgroundTask(Rec);
    end;
}
