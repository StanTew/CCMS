namespace D4P.CCMS.Auth;

page 62051 "D4P BC App Secret Expiries"
{
    ApplicationArea = All;
    Caption = 'App Secret Expirations';
    PageType = List;
    SourceTable = "D4P BC App Secret Expiry";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Secrets)
            {
                field("Tenant Name"; Rec."Tenant Name")
                {
                }
                field("Application Name"; Rec."Application Name")
                {
                }
                field("Application ID"; Rec."Application ID")
                {
                }
                field("Secret Name"; Rec."Secret Name")
                {
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    StyleExpr = ExpirationStyleExpr;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if DT2Date(Rec."Expiration Date") < Today then
            ExpirationStyleExpr := 'Unfavorable'
        else
            if DT2Date(Rec."Expiration Date") <= CalcDate('<30D>', Today) then
                ExpirationStyleExpr := 'Attention'
            else
                ExpirationStyleExpr := 'Favorable';
    end;

    var
        ExpirationStyleExpr: Text;
}