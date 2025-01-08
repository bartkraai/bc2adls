table 82571 "ADLSE Setup Companies"
{
    Access = Internal;
    Caption = 'ADLSE Table';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    
    fields
    {
        field(10;CompanyName; Code[20])
        {
            Caption = 'Company';
            NotBlank = true;
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
        field(50;"Last result";Text[250])
        {
            Caption = 'last result';
        }
        field(60;Enabled;Boolean)
        {
            Caption = 'enabled';
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
    
}