page 82578 "ADLSE Setup Companies"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ADLSE Setup Companies";
    Caption = 'ADLSE Setup Companies';
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(CompanyName;Rec.CompanyName)
                {
                    Caption = 'Company';
                    Editable = true;
                    ToolTip = 'Enter the name of the company.';
                }
                field("Sequence No.";Rec."Sequence No.")
                {
                    Caption = 'Sequence No.';
                    Editable = true;
                    ToolTip = 'Enter the sequence number.';
                }
                field("Date last started";Rec."Date last started")
                {
                    Editable = false;
                    ToolTip = 'last started.';
                }
                field("Date last ended";Rec."Date last ended")
                {
                    Editable = false;
                    ToolTip = 'date last ended.';
                }
                field("last result";Rec."Last result")
                {
                    Editable = false;
                    ToolTip = 'last result.';
                }
                field(Enabled;Rec.Enabled)
                {
                    Caption = 'enabled';
                    Editable = true;
                    ToolTip = 'Enter the enabled.';
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action("Refresh companies")
            {
                Caption = 'Refresh companies';
                ToolTip = 'Update companies in this list.';
                Image = Refresh;
                
                trigger OnAction()
                begin
                    Rec."Refresh companies"();                    
                end;
            }
        }
    }
}