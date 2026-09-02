namespace D4P.CCMS.Tenant;

using D4P.CCMS.Auth;

page 62012 "D4P BC Tenant FactBox"
{
    PageType = CardPart;
    SourceTable = "D4P BC Tenant";
    Caption = 'Tenant Details';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(GetEnvironments)
            {
                Caption = 'Get Environments';
                field("Tenant ID"; Rec."Tenant ID")
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
                    Visible = Rec."Get Environments Status" = Rec."Get Environments Status"::Error;
                }
            }
            group(Authentication)
            {
                Caption = 'Authentication';
                field("Client ID"; Rec."Client ID")
                {
                }
                field("Secret Expiration Date"; GetSecretExpirationDate())
                {
                    Caption = 'Secret Expiration Date';
                    ToolTip = 'Specifies when the client secret will expire.';
                }
            }
            group(Backup)
            {
                Caption = 'Backup Configuration';
                field("Backup SAS URI"; Rec."Backup SAS URI")
                {
                    ExtendedDatatype = Masked;
                }
                field("Backup Container Name"; Rec."Backup Container Name")
                {
                }
                field("Backup SAS Token Exp. Date"; Rec."Backup SAS Token Exp. Date")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec."Get Environments Status" of
            Rec."Get Environments Status"::Completed:
                GetEnvironmentsStatusStyleExpr := 'Favorable';
            Rec."Get Environments Status"::Pending:
                GetEnvironmentsStatusStyleExpr := 'Ambiguous';
            Rec."Get Environments Status"::Error:
                GetEnvironmentsStatusStyleExpr := 'Unfavorable';
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

    var
        GetEnvironmentsLastRunStyleExpr: Text;
        GetEnvironmentsStatusStyleExpr: Text;
        HasGetEnvironmentsError: Boolean;

    local procedure GetSecretExpirationDate(): Date
    var
        D4PBCAppRegistration: Record "D4P BC App Registration";
    begin
        case Rec."App Registration Type" of
            Rec."App Registration Type"::Shared:
                if D4PBCAppRegistration.Get(Rec."Client ID") then
                    exit(D4PBCAppRegistration."Secret Expiration Date")
                else
                    exit(0D);
            Rec."App Registration Type"::Individual:
                exit(Rec."Secret Expiration Date");
        end;
    end;
}
