namespace D4P.CCMS.Auth;

using D4P.CCMS.Customer;
using D4P.CCMS.Tenant;

table 62050 "D4P BC App Secret Expiry"
{
    Caption = 'App Secret Expiry';
    DataClassification = SystemMetadata;
    DrillDownPageId = "D4P BC App Secret Expiries";
    LookupPageId = "D4P BC App Secret Expiries";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "D4P BC Customer";
            ToolTip = 'Specifies the customer number associated with this application secret.';
        }
        field(2; "Tenant ID"; Guid)
        {
            Caption = 'Tenant ID';
            TableRelation = "D4P BC Tenant"."Tenant ID" where("Customer No." = field("Customer No."));
            ToolTip = 'Specifies the Microsoft Entra tenant that owns this application secret.';
        }
        field(3; "Application ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Specifies the unique identifier of the Microsoft Entra application.';
        }
        field(4; "Application Name"; Text[250])
        {
            Caption = 'Application Name';
            ToolTip = 'Specifies the name of the Microsoft Entra application.';
        }
        field(5; "Secret ID"; Guid)
        {
            Caption = 'Secret ID';
            ToolTip = 'Specifies the unique identifier of the application secret.';
        }
        field(6; "Secret Name"; Text[250])
        {
            Caption = 'Secret Name';
            ToolTip = 'Specifies the name or description of the application secret.';
        }
        field(7; "Expiration Date"; DateTime)
        {
            Caption = 'Expiration Date';
            ToolTip = 'Specifies the date and time when the application secret expires.';
        }
        field(8; "Tenant Name"; Text[100])
        {
            CalcFormula = lookup("D4P BC Tenant"."Tenant Name" where("Customer No." = field("Customer No."), "Tenant ID" = field("Tenant ID")));
            Caption = 'Tenant Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the Business Central tenant that owns this application secret.';
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Tenant ID", "Application ID", "Secret ID")
        {
            Clustered = true;
        }
    }
}