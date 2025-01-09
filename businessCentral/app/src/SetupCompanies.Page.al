page 82578 "ADLSE Setup Companies"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ADLSE Setup Companies";
    Caption = 'Companies';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = true;

    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Enabled;Rec.Enabled)
                {
                    Editable = true;
                }
                field(CompanyName;Rec.CompanyName)
                {
                    Caption = 'Company';
                    Editable = true;
                    ToolTip = 'Enter the name of the company.';
                }
                field("Date last started";Rec."Date last started")
                {
                    Editable = false;
                }
                
                field("Last message";Rec."Last message")
                {
                    Editable = false;
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
            action("Update Status")
            {
                Caption = 'Update Status';
                ToolTip = 'Update the status of the Export.';
                Image = Refresh;
                
                trigger OnAction()
                begin
                    Rec.GetSessionInfo();                    
                end;
            }
        }
    }
}