namespace D4P.CCMS.Tenant;

using D4P.CCMS.Auth;
using D4P.CCMS.Capacity;
using D4P.CCMS.Environment;
using D4P.CCMS.Extension;
using D4P.CCMS.Setup;

page 62002 "D4P BC Tenant List"
{
    ApplicationArea = All;
    Caption = 'D365BC Entra Tenants';
    CardPageId = "D4P BC Tenant Card";
    Editable = false;
    PageType = List;
    SourceTable = "D4P BC Tenant";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    DrillDown = false;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                }
                field("Partner Center Code"; Rec."Partner Center Code")
                {
                    Visible = false;
                }
                field(Blocked; Rec.Blocked)
                {
                }
                field("Get Environments Status"; Rec."Get Environments Status")
                {
                    StyleExpr = GetEnvironmentsStatusStyleExpr;
                }
                field("Get Environments Last Run"; Rec."Get Environments Last Run")
                {
                    StyleExpr = GetEnvironmentsLastRunStyleExpr;
                }
                field("Get Environments Error"; Rec."Get Environments Error")
                {
                    Style = Unfavorable;
                    StyleExpr = HasGetEnvironmentsError;
                }
            }
        }
        area(FactBoxes)
        {
            part(TenantDetails; "D4P BC Tenant FactBox")
            {
                SubPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
            }
            part(EnvironmentsFactBox; "D4P BC Environments FactBox")
            {
                SubPageLink = "Customer No." = field("Customer No."), "Tenant ID" = field("Tenant ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetAllEnvironmentsBackground)
            {
                Caption = 'Get All (Background)';
                Image = RefreshLines;
                ToolTip = 'Starts a background session for each non-blocked tenant to fetch the list of environments.';
                trigger OnAction()
                var
                    BCTenant: Record "D4P BC Tenant";
                    EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
                    TenantCount: Integer;
                    ConfirmMsg: Label 'This will delete all locally stored environment data for %1 tenant(s) and start a background session to load it again. Continue?', Comment = '%1 = Number of tenants';
                    NoTenantsErr: Label 'No tenants found.';
                    StartedMsg: Label 'Background retrieval of environments started for %1 tenant(s).', Comment = '%1 = Number of tenants';
                begin
                    BCTenant.SetRange(Blocked, false);
                    if not BCTenant.FindSet() then
                        Error(NoTenantsErr);

                    TenantCount := BCTenant.Count();
                    if not Confirm(ConfirmMsg, true, TenantCount) then
                        exit;

                    repeat
                        EnvironmentManagement.StartGetEnvironmentsBackground(BCTenant);
                    until BCTenant.Next() = 0;

                    Message(StartedMsg, TenantCount);
                    CurrPage.Update(false);
                end;
            }
            action(GetApplicationSecretExpirations)
            {
                Caption = 'Get App Secret Expirations';
                Image = Refresh;
                ToolTip = 'Retrieves the expiration dates of all application secrets for the selected tenant.';
                trigger OnAction()
                var
                    AppSecretExpiryMgt: Codeunit "D4P BC App Secret Expiry Mgt";
                begin
                    AppSecretExpiryMgt.GetApplicationSecretExpirations(Rec);
                end;
            }
            action(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                RunObject = page "D4P BC Setup";
                ToolTip = 'Configure D365BC Admin Center settings including debug mode.';
            }
            action(TestDebugMode)
            {
                Caption = 'Test Debug Mode';
                Image = TestReport;
                ToolTip = 'Test if debug mode is working properly.';
                trigger OnAction()
                var
                    DebugHelper: Codeunit "D4P BC Debug Helper";
                begin
                    DebugHelper.TestDebugMode();
                end;
            }
        }
        area(Navigation)
        {
            action(AdminCenter)
            {
                ApplicationArea = All;
                Caption = 'Admin Center';
                Image = LaunchWeb;
                ToolTip = 'Open the Dynamics 365 Business Central Admin Center for this tenant.';
                trigger OnAction()
                begin
                    Rec.OpenAdminCenter();
                end;
            }
            action(Environments)
            {
                Caption = 'Environments';
                Image = ViewDetails;
                RunObject = page "D4P BC Environment List";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View Business Central environments for this tenant.';
            }
            action(Capacity)
            {
                Caption = 'Capacity';
                Image = Capacity;
                ToolTip = 'View capacity information for all environments.';

                trigger OnAction()
                var
                    CapacityHeader: Record "D4P BC Capacity Header";
                    CapacityWorksheet: Page "D4P BC Capacity Worksheet";
                begin
                    CapacityHeader.SetRange("Customer No.", Rec."Customer No.");
                    CapacityHeader.SetRange("Tenant ID", Rec."Tenant ID");
                    CapacityWorksheet.SetTableView(CapacityHeader);
                    CapacityWorksheet.Run();
                end;
            }
            action(PTEObjectRanges)
            {
                Caption = 'PTE Object Ranges';
                Image = NumberSetup;
                RunObject = page "D4P PTE Object Ranges";
                RunPageLink = "Customer No." = field("Customer No."),
                            "Tenant ID" = field("Tenant ID");
                ToolTip = 'View PTE object ranges for this customer and tenant.';
            }
        }
        area(Promoted)
        {
            group(Category_Environment)
            {
                Caption = 'Environment Tasks';
                actionref(GetAllEnvironmentsPromoted; GetAllEnvironmentsBackground)
                {
                }
                actionref(GetApplicationSecretExpirationsPromoted; GetApplicationSecretExpirations)
                {
                }
            }
            group(Category_Navigation)
            {
                Caption = 'Navigation';
                actionref(AdminCenterPromoted; AdminCenter)
                {
                }
                actionref(EnvironmentsPromoted; Environments)
                {
                }
                actionref(CapacityPromoted; Capacity)
                {
                }
                actionref(PTEObjectRangesPromoted; PTEObjectRanges)
                {
                }
            }
            group(Category_Setup)
            {
                Caption = 'Setup';
                actionref(SetupPromoted; Setup)
                {
                }
                actionref(TestDebugModePromoted; TestDebugMode)
                {
                }
            }
        }
    }

    var
        GetEnvironmentsLastRunStyleExpr: Text;
        GetEnvironmentsStatusStyleExpr: Text;
        HasGetEnvironmentsError: Boolean;

    trigger OnAfterGetRecord()
    begin
        case Rec."Get Environments Status" of
            Rec."Get Environments Status"::Completed:
                GetEnvironmentsStatusStyleExpr := 'Favorable';
            Rec."Get Environments Status"::Error:
                GetEnvironmentsStatusStyleExpr := 'Unfavorable';
            Rec."Get Environments Status"::Pending:
                GetEnvironmentsStatusStyleExpr := 'Ambiguous';
            else
                GetEnvironmentsStatusStyleExpr := 'Standard';
        end;

        HasGetEnvironmentsError := Rec."Get Environments Error" <> '';
        if Rec."Get Environments Last Run" = 0DT then
            GetEnvironmentsLastRunStyleExpr := 'Standard'
        else
            if DT2Date(Rec."Get Environments Last Run") = Today then
                GetEnvironmentsLastRunStyleExpr := 'Favorable'
            else
                if DT2Date(Rec."Get Environments Last Run") = Today - 1 then
                    GetEnvironmentsLastRunStyleExpr := 'Ambiguous'
                else
                    GetEnvironmentsLastRunStyleExpr := 'Unfavorable';
    end;
}