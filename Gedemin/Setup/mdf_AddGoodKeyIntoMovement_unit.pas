unit mdf_AddGoodKeyIntoMovement_unit;

interface

uses
  IBDatabase, gdModify;

procedure AddGoodKeyIntoMovement(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, Controls, Dialogs, mdf_metadata_unit;

procedure AddGoodKeyIntoMovement(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      with FIBSQL do
      try
        Transaction := FTransaction;
        if not FieldExist2('INV_MOVEMENT', 'GOODKEY', FTransaction) then
        begin
          Log('���������� ������ �� ����� � inv_movement � inv_balance');
          Log('��������! ������ ��������� ����� ����������� ���������� �����. �� �������� ������!');
          Log('���������� ������ �� ����� � inv_movement');

          SQL.Text :=
            'ALTER TABLE inv_movement ADD goodkey dintkey';
          ExecQuery;
          Close;

          Log('���������� ������ �� ����� � inv_balance');
          SQL.Text :=
            'ALTER TABLE inv_balance ADD goodkey dintkey';
          ExecQuery;
          Close;

          Log('���������� �������� ��� ���������� GOODKEY � inv_balance');
          Close;
          ParamCheck := False;
          SQL.Text :=
          'CREATE TRIGGER INV_BI_BALANCE_GOODKEY FOR INV_BALANCE '#13#10 +
          'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT goodkey FROM inv_card '#13#10 +
          '  WHERE id = NEW.cardkey '#13#10 +
          '  INTO NEW.goodkey; '#13#10 +
          'END ';
          ExecQuery;
          Close;

          SQL.Text :=
          'CREATE TRIGGER INV_BU_BALANCE_GOODKEY FOR INV_BALANCE '#13#10 +
          'ACTIVE BEFORE UPDATE POSITION 10 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN '#13#10 +
          '    SELECT goodkey FROM inv_card '#13#10 +
          '    WHERE id = NEW.cardkey '#13#10 +
          '    INTO NEW.goodkey; '#13#10 +
          'END ';
          ExecQuery;
          Close;

          Log('���������� �������� ��� ���������� GOODKEY � inv_movement');
          Close;
          ParamCheck := False;
          SQL.Text :=
          'CREATE TRIGGER INV_BI_MOVEMENT_GOODKEY FOR INV_MOVEMENT '#13#10 +
          'ACTIVE BEFORE INSERT POSITION 10 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  SELECT goodkey FROM inv_card '#13#10 +
          '  WHERE id = NEW.cardkey '#13#10 +
          '  INTO NEW.goodkey; '#13#10 +
          'END ';
          ExecQuery;
          Close;

          SQL.Text :=
          'CREATE TRIGGER INV_BU_MOVEMENT_GOODKEY FOR INV_MOVEMENT '#13#10 +
          'ACTIVE BEFORE UPDATE POSITION 10 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN '#13#10 +
          '    SELECT goodkey FROM inv_card '#13#10 +
          '    WHERE id = NEW.cardkey '#13#10 +
          '    INTO NEW.goodkey; '#13#10 +
          'END ';
          ExecQuery;
          Close;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          Log('���������� �������� ��� ���������� GOODKEY � inv_card');

          SQL.Text :=
            'CREATE TRIGGER inv_bu_card_goodkey FOR inv_card '#13#10 +
            '  BEFORE UPDATE '#13#10 +
            '  POSITION 1 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF (NEW.GOODKEY <> OLD.GOODKEY) THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    UPDATE inv_movement SET goodkey = NEW.goodkey '#13#10 +
            '    WHERE cardkey = NEW.id; '#13#10 +
            ' '#13#10 +
            '    UPDATE inv_balance SET goodkey = NEW.goodkey '#13#10 +
            '    WHERE cardkey = NEW.id; '#13#10 +
            '  END '#13#10 +
            'END ';
          ExecQuery;
          Close;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          Log('���������� ���� GOODKEY  � INV_MOVEMENT');

          SQL.Text := 'UPDATE inv_movement SET id = id';
          ExecQuery;
          Close;

          Log('���������� ���� GOODKEY  � INV_BALANCE');

          SQL.Text := 'UPDATE inv_balance SET cardkey = cardkey ';
          ExecQuery;
          Close;

          FTransaction.Commit;

          IBDB.Connected := False;
          IBDB.Connected := True;
          FTransaction.StartTransaction;

          Log('���������� ������� � INV_MOVEMENT');

          SQL.Text := 'ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_goodk ' +
                      'FOREIGN KEY (goodkey) REFERENCES gd_good (id) ' +
                      'ON UPDATE CASCADE ';
          ExecQuery;
          Close;

          FTransaction.Commit;

          IBDB.Connected := False;
          IBDB.Connected := True;
          FTransaction.StartTransaction;

          Log('���������� ������� � INV_BALANCE');

          SQL.Text := 'ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_gk ' +
                      'FOREIGN KEY (goodkey) REFERENCES gd_good (id) ' +
                      'ON DELETE CASCADE ' +
                      'ON UPDATE CASCADE ';
          ExecQuery;
          Close;

          FTransaction.Commit;

          Log('���������� ���� GOODKEY � ������������� ��������� � �������� ������ �������');
        end;
        if not FTransaction.InTransaction then FTransaction.StartTransaction;
        try
          FIBSQL.Close;
          FIBSQL.ParamCheck := False;
          FIBSQL.SQL.Text :=
            'ALTER PROCEDURE INV_MAKEREST  '#13#10 +
            'AS '#13#10 +
            'DECLARE VARIABLE CONTACTKEY INTEGER; '#13#10 +
            'DECLARE VARIABLE CARDKEY INTEGER; '#13#10 +
            'DECLARE VARIABLE GOODKEY INTEGER; '#13#10 +
            'DECLARE VARIABLE BALANCE NUMERIC(15,4); '#13#10 +
            'BEGIN '#13#10 +
            '  DELETE FROM INV_BALANCE; '#13#10 +
            '  FOR '#13#10 +
            '    SELECT m.contactkey, m.goodkey, m.cardkey, SUM(m.debit - m.credit) '#13#10 +
            '      FROM '#13#10 +
            '        inv_movement m '#13#10 +
            '      WHERE disabled = 0 '#13#10 +
            '    GROUP BY m.contactkey, m.goodkey, m.cardkey '#13#10 +
            '    INTO :contactkey, :goodkey, :cardkey, :balance '#13#10 +
            '  DO '#13#10 +
            '    INSERT INTO inv_balance (contactkey, goodkey, cardkey, balance) '#13#10 +
            '      VALUES (:contactkey, :goodkey, :cardkey, :balance); '#13#10 +
            'END ';

          FIBSQL.ExecQuery;
        except
          FTransaction.Rollback;
        end;

        if FTransaction.InTransaction then
          FTransaction.Commit;

        FTransaction.StartTransaction;
        try
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            'VALUES (70, ''0000.0001.0000.0098'', ''10.01.2006'', ''Minor changes'') ' +
            'MATCHING (id)';
          FIBSQL.ExecQuery;
        finally
          FTransaction.Commit;
        end;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        Log('������ ��� ���������� ���� GOODKEY');
        Log(E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
