// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License. See LICENSE in the project root for license information.
codeunit 82569 "ADLSE Execution"
{
    trigger OnRun()
    begin
        StartExport();
    end;

    var
        EmitTelemetry: Boolean;
        ExportStartedTxt: Label 'Data export started for %1 out of %2 tables. Please refresh this page to see the latest export state for the tables. Only those tables that either have had changes since the last export or failed to export last time have been included. The tables for which the exports could not be started have been queued up for later.', Comment = '%1 = number of tables to start the export for. %2 = total number of tables enabled for export.';
        ExportStartedAllCompaniesTxt: Label 'Data export started for %1 companies. Please refresh this page to see the latest export state for the tables. Only those tables that either have had changes since the last export or failed to export last time have been included. The tables for which the exports could not be started have been queued up for later.';
        SuccessfulStopMsg: Label 'The export process was stopped successfully.';
        ClearSchemaExportedOnMsg: Label 'The schema export date has been cleared.';


    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Table", 'r')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Field", 'r')]
    internal procedure StartExport()
    var
        AdlseTable: Record "ADLSE Table";
    begin
        StartExport(AdlseTable);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Table", 'r')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Field", 'r')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE setup companies", 'rm')]
    internal procedure StartExportAllCompanies()
    var
        ADLSESetupCompanies: Record "ADLSE Setup Companies";
        ADLSESetupRec: Record "ADLSE Setup";
        AdlseTable: Record "ADLSE Table";
        ADLSEField: Record "ADLSE Field";
        ADLSECurrentSession: Record "ADLSE Current Session";
        ADLSESetup: Codeunit "ADLSE Setup";
        ADLSECommunication: Codeunit "ADLSE Communication";
        ADLSESessionManager: Codeunit "ADLSE Session Manager";
        ADLSEExternalEvents: Codeunit "ADLSE External Events";
        Counter: Integer;
        Started: Integer;
        NewSessionID: Integer;
    begin
        ADLSESetup.CheckSetup(ADLSESetupRec);
        EmitTelemetry := ADLSESetupRec."Emit telemetry";
        ADLSECurrentSession.CleanupSessions();
        if ADLSESetupRec.GetStorageType() = ADLSESetupRec."Storage Type"::"Azure Data Lake" then //Because Fabric doesn't have do create a container
            ADLSECommunication.SetupBlobStorage();
        ADLSESessionManager.Init();

        ADLSEExternalEvents.OnExport(ADLSESetupRec);

        if EmitTelemetry then
            Log('ADLSE-022', 'Starting export for all tables', Verbosity::Normal);
        ADLSESetupCompanies.SetRange(Enabled, true);
        if ADLSESetupCompanies.FindSet() then begin
            repeat
                Counter += 1;

                Session.StartSession(NewSessionID, Codeunit::"ADLSE Execution", ADLSESetupCompanies.CompanyName);

                ADLSESetupCompanies."Date last started" := CurrentDateTime();
                ADLSESetupCompanies.LastSessionId := NewSessionID;
                ADLSESetupCompanies.GetSessionInfo();
                ADLSESetupCompanies.Modify(false);
            until ADLSESetupCompanies.Next() = 0;

            Message(ExportStartedAllCompaniesTxt, Counter);
            if EmitTelemetry then
                Log('ADLSE-001', StrSubstNo(ExportStartedAllCompaniesTxt, Counter), Verbosity::Normal);

            ADLSEExternalEvents.OnAllExportIsFinished(ADLSESetupRec);
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Table", 'r')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Field", 'r')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE setup companies", 'rm')]
    internal procedure StartExport(var AdlseTable: Record "ADLSE Table")
    var
        ADLSESetupCompanies: Record "ADLSE Setup Companies";
        ADLSESetupRec: Record "ADLSE Setup";
        ADLSEField: Record "ADLSE Field";
        ADLSECurrentSession: Record "ADLSE Current Session";
        ADLSESetup: Codeunit "ADLSE Setup";
        ADLSECommunication: Codeunit "ADLSE Communication";
        ADLSESessionManager: Codeunit "ADLSE Session Manager";
        ADLSEExternalEvents: Codeunit "ADLSE External Events";
        Counter: Integer;
        Started: Integer;
    begin
        ADLSESetup.CheckSetup(ADLSESetupRec);
        EmitTelemetry := ADLSESetupRec."Emit telemetry";
        ADLSECurrentSession.CleanupSessions();
        if ADLSESetupRec.GetStorageType() = ADLSESetupRec."Storage Type"::"Azure Data Lake" then //Because Fabric doesn't have do create a container
            ADLSECommunication.SetupBlobStorage();
        ADLSESessionManager.Init();

        if ADLSESetupCompanies.Get(CompanyName) then;

        ADLSEExternalEvents.OnExport(ADLSESetupRec);

        if EmitTelemetry then
            Log('ADLSE-022', 'Starting export for all tables', Verbosity::Normal);
        AdlseTable.SetRange(Enabled, true);
        if AdlseTable.FindSet(false) then
            repeat
                Counter += 1;
                ADLSEField.SetRange("Table ID", ADLSETable."Table ID");
                ADLSEField.SetRange(Enabled, true);
                if not ADLSEField.IsEmpty() then
                    if ADLSESessionManager.StartExport(AdlseTable."Table ID", EmitTelemetry) then
                        Started += 1;
            until AdlseTable.Next() = 0;

        ADLSESetupCompanies."Last message" := StrSubstNo(ExportStartedTxt, Started, Counter);
        if ADLSESetupCompanies.Modify(false) then;

        if GuiAllowed then Message(ExportStartedTxt, Started, Counter);
        if EmitTelemetry then
            Log('ADLSE-001', StrSubstNo(ExportStartedTxt, Started, Counter), Verbosity::Normal);

        ADLSEExternalEvents.OnAllExportIsFinished(ADLSESetupRec);
    end;

    internal procedure StopExport()
    var
        ADLSESetup: Record "ADLSE Setup";
        ADLSERun: Record "ADLSE Run";
        ADLSECurrentSession: Record "ADLSE Current Session";
    begin
        ADLSESetup.GetSingleton();
        if ADLSESetup."Emit telemetry" then
            Log('ADLSE-003', 'Stopping export sessions', Verbosity::Normal);

        ADLSECurrentSession.CancelAll();

        ADLSERun.CancelAllRuns();

        Message(SuccessfulStopMsg);
        if ADLSESetup."Emit telemetry" then
            Log('ADLSE-019', 'Stopped export sessions', Verbosity::Normal);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Table", 'r')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Setup", 'm')]
    internal procedure SchemaExport()
    var
        ADLSESetup: Record "ADLSE Setup";
        AdlseTable: Record "ADLSE Table";
        ADLSECurrentSession: Record "ADLSE Current Session";
        AllObjWithCaption: Record AllObjWithCaption;
        ADLSEExecute: Codeunit "ADLSE Execute";
        ADLSEExternalEvents: Codeunit "ADLSE External Events";
        ProgressWindowDialog: Dialog;
        Progress1Msg: Label 'Current Table:           #1##########\', Comment = '#1: table caption';
    begin
        // ensure that no current export sessions running
        ADLSECurrentSession.CheckForNoActiveSessions();

        AdlseTable.Reset();
        AdlseTable.SetRange(Enabled, true);
        if AdlseTable.FindSet(false) then
            if GuiAllowed() then
                ProgressWindowDialog.Open(Progress1Msg);
        repeat
            if GuiAllowed() then begin
                AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                AllObjWithCaption.SetRange("Object ID", AdlseTable."Table ID");
                if AllObjWithCaption.FindFirst() then
                    if GuiAllowed() then
                        ProgressWindowDialog.Update(1, AllObjWithCaption."Object Caption");
            end;

            ADLSEExecute.ExportSchema(AdlseTable."Table ID");
        until AdlseTable.Next() = 0;

        if GuiAllowed() then
            ProgressWindowDialog.Close();

        ADLSESetup.GetSingleton();
        ADLSESetup."Schema Exported On" := CurrentDateTime();
        ADLSESetup.Modify(true);

        ADLSEExternalEvents.OnExportSchema(ADLSESetup);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Setup", 'm')]
    internal procedure ClearSchemaExportedOn()
    var
        ADLSESetup: Record "ADLSE Setup";
        ADLSEExternalEvents: Codeunit "ADLSE External Events";
    begin
        ADLSESetup.GetSingleton();
        ADLSESetup."Schema Exported On" := 0DT;
        ADLSESetup.Modify(true);
        if GuiAllowed() then
            Message(ClearSchemaExportedOnMsg);

        ADLSEExternalEvents.OnClearSchemaExportedOn(ADLSESetup);
    end;

    internal procedure ScheduleExport()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ADLSEScheduleTaskAssignment: Report "ADLSE Schedule Task Assignment";
        SavedData: Text;
        xmldata: Text;
        Handled: Boolean;
    begin
        OnBeforeScheduleExport(Handled);
        if Handled then
            exit;

        JobQueueEntry.SetFilter("User ID", UserId());
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"ADLSE Schedule Task Assignment");
        JobQueueEntry.SetCurrentKey(SystemCreatedAt);
        JobQueueEntry.SetAscending(SystemCreatedAt, false);

        if JobQueueEntry.FindFirst() then
            SavedData := JobQueueEntry.GetReportParameters();

        xmldata := ADLSEScheduleTaskAssignment.RunRequestPage(SavedData);

        if xmldata <> '' then begin
            ADLSEScheduleTaskAssignment.CreateJobQueueEntry(JobQueueEntry);
            JobQueueEntry.SetReportParameters(xmldata);
            JobQueueEntry.Modify();
        end;
    end;

    internal procedure Log(EventId: Text; Message: Text; Verbosity: Verbosity)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        Log(EventId, Message, Verbosity, CustomDimensions);
    end;

    internal procedure Log(EventId: Text; Message: Text; Verbosity: Verbosity; CustomDimensions: Dictionary of [Text, Text])
    begin
        Session.LogMessage(EventId, Message, Verbosity, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    [InherentPermissions(PermissionObjectType::Table, Database::"ADLSE Table Last Timestamp", 'X')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Table Last Timestamp", 'R')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterGetDatabaseTableTriggerSetup, '', true, true)]
    local procedure GetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    var
        AdlseTableLastTimestamp: Record "ADLSE Table Last Timestamp";
    begin
        if CompanyName() = '' then
            exit;

        // track deletes only if at least one export has been made for that table
        if AdlseTableLastTimestamp.ExistsUpdatedLastTimestamp(TableId) then
            OnDatabaseDelete := true;
    end;

    [InherentPermissions(PermissionObjectType::Table, Database::"ADLSE Table Last Timestamp", 'X')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Table Last Timestamp", 'R')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"ADLSE Deleted Record", 'RI')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"Deleted Tables Not to Sync", 'r')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseDelete, '', true, true)]
    local procedure OnAfterOnDatabaseDelete(RecRef: RecordRef)
    var
        AdlseTableLastTimestamp: Record "ADLSE Table Last Timestamp";
        ADLSEDeletedRecord: Record "ADLSE Deleted Record";
        DeletedTablesNottoSync: Record "Deleted Tables Not to Sync";
    begin
        if RecRef.Number = Database::"ADLSE Deleted Record" then
            exit;

        if DeletedTablesNottoSync.Get(RecRef.Number) then
            exit;

        // check if table is to be tracked.
        if not AdlseTableLastTimestamp.ExistsUpdatedLastTimestamp(RecRef.Number) then
            exit;

        ADLSEDeletedRecord.TrackDeletedRecord(RecRef);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleExport(var Handled: Boolean)
    begin

    end;
}