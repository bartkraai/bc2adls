table 82571 "ADLSE Setup Companies"
{
    Access = Internal;
    Caption = 'ADLSE Table';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    
    fields
    {
        field(10;CompanyName; Text[30])
        {
            Caption = 'Company';
            NotBlank = true;
            TableRelation = Company.Name;
        }
        field(20;"Sequence No.";Integer)
        {
            Caption = 'Sequence No.';
        }
        field(30;"Date last started";DateTime)
        {
            Caption = 'Date last started';
        }
        field(40;"Date last ended";DateTime)
        {
            Caption = 'Date last ended';
        }
        field(50;"Last message";Text[1024])
        {
            Caption = 'last result';
        }
        field(60;Enabled;Boolean)
        {
            Caption = 'enabled';
        }
        field(70;LastSessionId;Integer)
        {
            Caption = 'Last run session id';
        }
        field(80;ExportRunning;Boolean)
        {
            Caption = 'Export running';
        }
    }
    
    keys
    {
        key(Key1; CompanyName)
        {
            Clustered = true;
        }
        key(Key2; "Sequence No.")
        {
        }
    }
    
    fieldgroups
    {
        // Add changes to field groups here
    }
    
    trigger OnInsert()
    begin
        
    end;
    
    trigger OnModify()
    begin
        //TODO: implement code if disabled to remove company specific data.
        
    end;
    
    trigger OnDelete()
    begin
        //TODO: implement code if disabled to remove company specific data.
    end;

    procedure "Refresh companies"()
    begin
        //TODO: Implement this method, build up the list of companies.
    end;

    procedure GetSessionInfo()
    var
    begin
        Rec.ExportRunning := Session.IsSessionActive(Rec.LastSessionId);
        Rec.Modify(false);
    end;
    
}