namespace D4P.CCMS.Auth;

using D4P.CCMS.Connector;
using D4P.CCMS.Tenant;
using System.RestClient;

codeunit 62042 "D4P BC App Secret Expiry Mgt"
{
    procedure GetApplicationSecretExpirations(BCTenant: Record "D4P BC Tenant")
    var
        AppSecretExpiry: Record "D4P BC App Secret Expiry";
        RestClientFactory: Codeunit D4PBCRestClientFactory;
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        Applications: JsonArray;
        ApplicationToken: JsonToken;
        ApplicationObject: JsonObject;
        CredentialToken: JsonToken;
        Credentials: JsonArray;
        CredentialObject: JsonObject;
        JsonResponse: JsonObject;
        JsonValue: JsonValue;
        FailedToFetchErr: Label 'Failed to retrieve application secret expirations: %1', Comment = '%1 = Error message';
    begin
        RestClient := RestClientFactory.CreateRestClientForMicrosoftGraph(BCTenant);
        HttpResponseMessage := RestClient.Get('/v1.0/applications?$select=appId,displayName,passwordCredentials&$top=999');
        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(FailedToFetchErr, HttpResponseMessage.GetErrorMessage());

        JsonResponse := HttpResponseMessage.GetContent().AsJson().AsObject();
        if not JsonResponse.Get('value', ApplicationToken) then
            exit;

        AppSecretExpiry.SetRange("Customer No.", BCTenant."Customer No.");
        AppSecretExpiry.SetRange("Tenant ID", BCTenant."Tenant ID");
        AppSecretExpiry.DeleteAll();

        Applications := ApplicationToken.AsArray();
        foreach ApplicationToken in Applications do begin
            ApplicationObject := ApplicationToken.AsObject();
            if not ApplicationObject.Get('passwordCredentials', CredentialToken) then
                continue;

            Credentials := CredentialToken.AsArray();
            foreach CredentialToken in Credentials do begin
                CredentialObject := CredentialToken.AsObject();
                AppSecretExpiry.Init();
                AppSecretExpiry."Customer No." := BCTenant."Customer No.";
                AppSecretExpiry."Tenant ID" := BCTenant."Tenant ID";

                if ApplicationObject.Get('appId', CredentialToken) then begin
                    JsonValue := CredentialToken.AsValue();
                    Evaluate(AppSecretExpiry."Application ID", JsonValue.AsText());
                end;
                if ApplicationObject.Get('displayName', CredentialToken) then begin
                    JsonValue := CredentialToken.AsValue();
                    if not JsonValue.IsNull() then
                        AppSecretExpiry."Application Name" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(AppSecretExpiry."Application Name"));
                end;
                if CredentialObject.Get('keyId', CredentialToken) then begin
                    JsonValue := CredentialToken.AsValue();
                    Evaluate(AppSecretExpiry."Secret ID", JsonValue.AsText());
                end;
                if CredentialObject.Get('displayName', CredentialToken) then begin
                    JsonValue := CredentialToken.AsValue();
                    if not JsonValue.IsNull() then
                        AppSecretExpiry."Secret Name" := CopyStr(JsonValue.AsText(), 1, MaxStrLen(AppSecretExpiry."Secret Name"));
                end;
                if CredentialObject.Get('endDateTime', CredentialToken) then begin
                    JsonValue := CredentialToken.AsValue();
                    AppSecretExpiry."Expiration Date" := JsonValue.AsDateTime();
                end;
                AppSecretExpiry.Insert();
            end;
        end;
    end;
}