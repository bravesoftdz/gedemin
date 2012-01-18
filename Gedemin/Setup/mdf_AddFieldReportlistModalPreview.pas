unit mdf_AddFieldReportlistModalPreview;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldReportlistModalPreview(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit; 

procedure AddFieldReportlistModalPreview(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FIBSQL := TIBSQL.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL.Transaction := FTransaction;
      FTransaction.StartTransaction;

      DropField2('RP_REPORTLIST', 'MODALPREVIEW', FTRansaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      AddField2('RP_REPORTLIST', 'MODALPREVIEW', 'dboolean_notnull DEFAULT 0', FTransaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'UPDATE rp_reportlist SET modalpreview = 0';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (136, ''0000.0001.0000.0167'', ''12.01.2012'', ''Add field modalpreview to the table rp_reportlist'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('��������� ������: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

end.
