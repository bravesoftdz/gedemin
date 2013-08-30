
unit gdcNamespaceSyncController;

interface

uses
  Classes, DB, IBDatabase, IBSQL, IBCustomDataSet;

type
  TOnLogMessage = procedure(const AMessage: String) of object;

  TgdcNamespaceSyncController = class(TObject)
  private
    FTr: TIBTransaction;
    FqInsertFile: TIBSQL;
    FqFindFile: TIBSQL;
    FqFindDirectory: TIBSQL;
    FqInsertLink: TIBSQL;
    FqFillSync: TIBSQL;
    FDataSet: TIBDataSet;
    FDirectory: String;
    FUpdateCurrModified: Boolean;
    FOnLogMessage: TOnLogMessage;
    FFilterOnlyPackages: Boolean;
    FFilterText: String;
    FFilterOperation: String;
    Fq: TIBSQL;
    FqUpdateOperation: TIBSQL;

    procedure Init;
    procedure DoLog(const AMessage: String);
    procedure AnalyzeFile(const AFileName: String);
    function GetDataSet: TDataSet;
    function GetFiltered: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Scan;
    procedure ApplyFilter;
    procedure DeleteFile(const AFileName: String);
    procedure SetOperation(const AnOp: String);

    property Directory: String read FDirectory write FDirectory;
    property UpdateCurrModified: Boolean read FUpdateCurrModified write FUpdateCurrModified;
    property OnLogMessage: TOnLogMessage read FOnLogMessage write FOnLogMessage;
    property DataSet: TDataSet read GetDataSet;
    property FilterOnlyPackages: Boolean read FFilterOnlyPackages write FFilterOnlyPackages;
    property FilterText: String read FFilterText write FFilterText;
    property FilterOperation: String read FFilterOperation write FFilterOperation;
    property Filtered: Boolean read GetFiltered;
  end;

implementation

uses
  SysUtils, jclFileUtils, gdcBaseInterface, gdcBase, gdcNamespace,
  gd_GlobalParams_unit, yaml_parser, gd_common_functions;

{ TgdcNamespaceSyncController }

procedure TgdcNamespaceSyncController.AnalyzeFile(const AFileName: String);
var
  Parser: TyamlParser;
  M: TyamlMapping;
  S: TyamlSequence;
  I: Integer;
  NSRUID, UsesRuid: TRUID;
  UsesName: String;
begin
  FqFindDirectory.ParamByName('filename').AsString := ExtractFilePath(AFileName);
  FqFindDirectory.ExecQuery;

  if FqFindDirectory.EOF then
  begin
    FqInsertFile.ParamByName('filename').AsString := ExtractFilePath(AFileName);
    FqInsertFile.ParamByName('filetimestamp').Clear;
    FqInsertFile.ParamByName('filesize').Clear;
    FqInsertFile.ParamByName('name').AsString := ExtractFilePath(AFileName);
    FqInsertFile.ParamByName('caption').AsString := ExtractFilePath(AFileName);
    FqInsertFile.ParamByName('version').Clear;
    FqInsertFile.ParamByName('dbversion').Clear;
    FqInsertFile.ParamByName('optional').AsInteger := 0;
    FqInsertFile.ParamByName('internal').AsInteger := 0;
    FqInsertFile.ParamByName('comment').Clear;
    FqInsertFile.ParamByName('xid').Clear;
    FqInsertFile.ParamByName('dbid').Clear;
    FqInsertFile.ExecQuery;
  end;

  FqFindDirectory.Close;

  Parser := TyamlParser.Create;
  try
    Parser.Parse(AFileName, 'Objects', 8192);

    if (Parser.YAMLStream.Count > 0)
      and ((Parser.YAMLStream[0] as TyamlDocument).Count > 0)
      and ((Parser.YAMLStream[0] as TyamlDocument)[0] is TyamlMapping)
      and (((Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping).ReadString('Properties\Name') > '') then
    begin
      M := (Parser.YAMLStream[0] as TyamlDocument)[0] as TyamlMapping;
      NSRUID := StrToRUID(M.ReadString('Properties\RUID'));

      FqFindFile.Close;
      FqFindFile.ParamByName('name').AsString := M.ReadString('Properties\Name');
      FqFindFile.ParamByName('xid').AsInteger := NSRUID.XID;
      FqFindFile.ParamByName('dbid').AsInteger := NSRUID.DBID;
      FqFindFile.ExecQuery;

      if not FqFindFile.EOF then
      begin
        DoLog(
          '������������ ����: "' + M.ReadString('Properties\Name') + '" ���������� � ������:' + #13#10 +
          '1: ' + FqFindFile.FieldByName('filename').AsString + #13#10 +
          '2: ' + AFileName + #13#10 +
          '������ ������ ���� ����� ���������!');
      end else
      begin
        FqInsertFile.ParamByName('filename').AsString := AFileName;
        FqInsertFile.ParamByName('filetimestamp').AsDateTime := gd_common_functions.GetFileLastWrite(AFileName);
        FqInsertFile.ParamByName('filesize').AsInteger := FileGetSize(AFileName);
        FqInsertFile.ParamByName('name').AsString := M.ReadString('Properties\Name');
        FqInsertFile.ParamByName('caption').AsString := M.ReadString('Properties\Caption');
        FqInsertFile.ParamByName('version').AsString := M.ReadString('Properties\Version');
        FqInsertFile.ParamByName('dbversion').AsString := M.ReadString('Properties\DBVersion');
        FqInsertFile.ParamByName('optional').AsInteger := M.ReadInteger('Properties\Optional');
        FqInsertFile.ParamByName('internal').AsInteger := M.ReadInteger('Properties\Internal');
        FqInsertFile.ParamByName('comment').AsString := M.ReadString('Properties\Comment');
        FqInsertFile.ParamByName('xid').AsInteger := NSRUID.XID;
        FqInsertFile.ParamByName('dbid').AsInteger := NSRUID.DBID;
        FqInsertFile.ExecQuery;

        if M.FindByName('Uses') is TYAMLSequence then
        begin
          S := M.FindByName('Uses') as TyamlSequence;
          for I := 0 to S.Count - 1 do
          begin
            if not (S.Items[I] is TyamlString) then
              DoLog('������ � ������ USES ����� ' + AFileName)
            else begin
              TgdcNamespace.ParseReferenceString((S.Items[I] as TyamlString).AsString, UsesRUID, UsesName);

              FqInsertLink.ParamByName('filename').AsString := AFileName;
              FqInsertLink.ParamByName('uses_xid').AsInteger := UsesRUID.XID;
              FqInsertLink.ParamByName('uses_dbid').AsInteger := UsesRUID.DBID;
              FqInsertLink.ParamByName('uses_name').AsString := UsesName;
              FqInsertLink.ExecQuery;
            end;
          end;
        end;
        DoLog(AFileName);
      end;
    end else
      DoLog('�������� ������ ����� ' + AFileName);
  finally
    Parser.Free;
  end;
end;

procedure TgdcNamespaceSyncController.ApplyFilter;
var
  NK: Integer;
  FN: String;
begin
  if not FDataSet.EOF then
  begin
    NK := FDataSet.FieldByName('namespacekey').AsInteger;
    FN := FDataSet.FieldByName('filename').AsString;
  end else
  begin
    NK := 0;
    FN := '';
  end;

  FDataSet.DisableControls;
  try
    FDataSet.Close;
    FDataSet.SelectSQL.Text :=
      'SELECT ' +
      '  n.id AS NamespaceKey, ' +
      '  n.name AS NamespaceName, ' +
      '  n.version AS NamespaceVersion, ' +
      '  n.filetimestamp AS NamespaceTimestamp, ' +
      '  n.internal AS NamespaceInternal, ' +
      '  s.operation, ' +
      '  f.filename, ' +
      '  f.name AS FileNamespaceName, ' +
      '  f.version AS FileVersion, ' +
      '  f.filetimestamp AS FileTimeStamp, ' +
      '  f.filesize AS FileSize, ' +
      '  (f.xid || ''_'' || f.dbid) AS FileRUID, ' +
      '  f.internal AS FileInternal ' +
      'FROM ' +
      '  at_namespace_sync s ' +
      '  LEFT JOIN at_namespace n ON n.id = s.namespacekey ' +
      '  LEFT JOIN at_namespace_file f ON f.filename = s.filename ';

    if FFilterOnlyPackages or (FFilterText > '') or (FFilterOperation > '') then
    begin
      FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
        'WHERE (s.operation = ''  '') OR (';

      if FFilterOnlyPackages then
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '((n.id IS NOT NULL AND n.internal = 0) OR (f.name IS NOT NULL AND f.internal = 0))';

      if FFilterText > '' then
      begin
        if FFilterOnlyPackages then
          FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' AND ';
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '(POSITION(:t IN UPPER(' +
          '  COALESCE(n.name, '''') || ' +
          '  COALESCE(n.version, '''') || ' +
          '  COALESCE(n.filetimestamp, '''') || ' +
          '  COALESCE(f.filename, '''') || ' +
          '  COALESCE(f.name, '''') || ' +
          '  COALESCE(f.version, '''') || ' +
          '  COALESCE(f.filetimestamp, ''''))) > 0)';
      end;

      if FFilterOperation > '' then
      begin
        if FFilterOnlyPackages or (FFilterText > '') then
          FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ' AND ';
        FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
          '(POSITION(CAST(s.operation AS VARCHAR(1024)) IN :op) > 0)';
      end;

      FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text + ')';
    end;

    FDataSet.SelectSQL.Text := FDataSet.SelectSQL.Text +
      'ORDER BY ' +
      '  f.filename';

    if FFilterText > '' then
      FDataSet.ParamByName('t').AsString := AnsiUpperCase(FFilterText);

    if FFilterOperation > '' then
      FDataSet.ParamByName('op').AsString := FFilterOperation;

    FDataSet.Open;

    if (NK = 0) or (not FDataSet.Locate('namespacekey', NK, [])) then
    begin
      if FN > '' then
        FDataSet.Locate('filename', FN, []);
    end;
  finally
    FDataSet.EnableControls;
  end;
end;

constructor TgdcNamespaceSyncController.Create;
begin
  FUpdateCurrModified := True;
  FDirectory := gd_GlobalParams.NamespacePath;
  FDataSet := TIBDataSet.Create(nil);
end;

procedure TgdcNamespaceSyncController.DeleteFile(const AFileName: String);
begin
  if SysUtils.DeleteFile(AFileName) then
  begin
    DoLog('���� ' + AFileName + ' ��� ������.');

    Fq.Close;
    Fq.SQL.Text :=
      'DELETE FROM at_namespace_file WHERE UPPER(filename) = :fn';
    Fq.ParamByName('fn').AsString := AnsiUpperCase(AFileName);
    Fq.ExecQuery;
  end;
end;

destructor TgdcNamespaceSyncController.Destroy;
begin
  FqUpdateOperation.Free;
  Fq.Free;
  FDataSet.Free;
  FqFillSync.Free;
  FqFindDirectory.Free;
  FqInsertLink.Free;
  FqFindFile.Free;
  FqInsertFile.Free;
  FTr.Free;
  inherited;
end;

procedure TgdcNamespaceSyncController.DoLog(const AMessage: String);
begin
  if Assigned(FOnLogMessage) then
    FOnLogMessage(AMessage);
end;

function TgdcNamespaceSyncController.GetDataSet: TDataSet;
begin
  Result := FDataSet as TDataSet;
end;

function TgdcNamespaceSyncController.GetFiltered: Boolean;
begin
  Result := FFilterOnlyPackages
    or (FFilterText > '')
    or (FFilterOperation > '');
end;

procedure TgdcNamespaceSyncController.Init;
begin
  Assert(gdcBaseManager <> nil);

  if FTr <> nil then
  begin
    FTr.Commit;
    FTr.StartTransaction;
    exit;
  end;

  FTr := TIBTransaction.Create(nil);
  FTr.DefaultDatabase := gdcBaseManager.Database;
  FTr.Params.CommaText := 'read_committed,rec_version,nowait';
  FTr.StartTransaction;

  FqInsertFile := TIBSQL.Create(nil);
  FqInsertFile.Transaction := FTr;
  FqInsertFile.SQL.Text :=
    'INSERT INTO at_namespace_file ' +
    '  (filename, filetimestamp, filesize, name, caption, version, ' +
    '   dbversion, optional, internal, comment, xid, dbid) ' +
    'VALUES ' +
    '  (:filename, :filetimestamp, :filesize, :name, :caption, :version, ' +
    '   :dbversion, :optional, :internal, :comment, :xid, :dbid)';

  FqFindFile := TIBSQL.Create(nil);
  FqFindFile.Transaction := FTr;
  FqFindFile.SQL.Text :=
    'SELECT * FROM at_namespace_file ' +
    'WHERE (xid = :xid AND dbid = :dbid) OR (name = :name)';

  FqInsertLink := TIBSQL.Create(nil);
  FqInsertLink.Transaction := FTr;
  FqInsertLink.SQL.Text :=
    'INSERT INTO at_namespace_file_link ' +
    '  (filename, uses_xid, uses_dbid, uses_name) ' +
    'VALUES ' +
    '  (:filename, :uses_xid, :uses_dbid, :uses_name)';

  FqFindDirectory := TIBSQL.Create(nil);
  FqFindDirectory.Transaction := FTr;
  FqFindDirectory.SQL.Text :=
    'SELECT * FROM at_namespace_file ' +
    'WHERE filename = :filename AND xid IS NULL AND dbid IS NULL';

  FqFillSync := TIBSQL.Create(nil);
  FqFillSync.Transaction := FTr;
  FqFillSync.SQL.Text :=
    'EXECUTE BLOCK ' +
    'AS ' +
    'BEGIN ' +
    '  INSERT INTO at_namespace_sync (namespacekey) ' +
    '  SELECT id FROM at_namespace; ' +
    ' ' +
    '  MERGE INTO at_namespace_sync s ' +
    '  USING ( ' +
    '    SELECT f.filename, n.id, f.xid ' +
    '    FROM at_namespace_file f ' +
    '      LEFT JOIN gd_ruid r ' +
    '        ON r.xid = f.xid AND r.dbid = f.dbid ' +
    '      LEFT JOIN at_namespace n ' +
    '        ON (r.id = n.id) OR (n.name = f.name) ' +
    '    ) j ' +
    '  ON (s.namespacekey = j.id) ' +
    '  WHEN MATCHED THEN UPDATE SET filename = j.filename ' +
    '  WHEN NOT MATCHED THEN INSERT (filename, operation) ' +
    '    VALUES (j.filename, IIF(j.xid IS NULL, ''  '', ''< '')); ' +
    ' ' +
    '  UPDATE at_namespace_sync SET operation = ''> '' ' +
    '  WHERE namespacekey IS NOT NULL ' +
    '    AND filename IS NULL; ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ''>>'' ' +
    '  WHERE ' +
    '    (EXISTS (SELECT * FROM at_object o ' +
    '       WHERE o.namespacekey = s.namespacekey ' +
    '         AND DATEDIFF(SECOND, o.modified, o.curr_modified) >= 1) ' +
    '     OR ' +
    '     (SELECT n.filetimestamp FROM at_namespace n ' +
    '       WHERE n.id = s.namespacekey) > ' +
    '     (SELECT f.filetimestamp FROM at_namespace_file  f ' +
    '       WHERE f.filename = s.filename) ' +
    '    ) ' +
    '    AND (s.operation = ''  ''); ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ' +
    '    iif(s.operation = ''  '', ''<<'', ''? '') ' +
    '  WHERE ' +
    '    (SELECT f.filetimestamp FROM at_namespace_file f ' +
    '      WHERE f.filename = s.filename) > ' +
    '    (SELECT n.filetimestamp FROM at_namespace n ' +
    '      WHERE n.id = s.namespacekey) ' +
    '    AND (s.operation = ''  ''); ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ''! '' ' +
    '  WHERE ' +
    '    EXISTS (' +
    '      SELECT * FROM at_namespace_file_link l ' +
    '        LEFT JOIN ' +
    '       (SELECT r.xid, r.dbid FROM gd_ruid r JOIN at_namespace n ' +
    '          ON n.id = r.id ' +
    '        UNION ' +
    '        SELECT f.xid, f.dbid FROM at_namespace_file f) j ' +
    '        ON l.uses_xid = j.xid AND l.uses_dbid = j.dbid ' +
    '      WHERE l.filename = s.filename AND j.xid IS NULL) ' +
    '    AND (s.operation IN (''<<'', ''< '')); ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ''=='' ' +
    '  WHERE s.operation = ''  '' AND s.namespacekey IS NOT NULL ' +
    '    AND s.filename IS NOT NULL; ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ''<='' ' +
    '  WHERE s.operation = ''=='' AND EXISTS (' +
    '    SELECT * FROM at_namespace_sync y JOIN at_namespace_file f ' +
    '      ON y.filename = f.filename ' +
    '    JOIN at_namespace_file_link l ' +
    '      ON l.uses_xid = f.xid AND l.uses_dbid = f.dbid ' +
    '    WHERE l.filename = s.filename ' +
    '      AND y.operation IN (''<<'', ''< '', ''<='')); ' +
    ' ' +
    '  UPDATE at_namespace_sync s SET s.operation = ''=>'' ' +
    '  WHERE s.operation = ''=='' AND EXISTS (' +
    '    SELECT * FROM at_namespace_sync y ' +
    '    JOIN at_namespace_link l ' +
    '      ON l.useskey = y.namespacekey ' +
    '    WHERE l.namespacekey = s.namespacekey ' +
    '      AND y.operation IN (''>>'', ''> '', ''=>'')); ' +
    'END';

  FDataSet.ReadTransaction := FTr;
  FDataSet.Transaction := FTr;

  Fq := TIBSQL.Create(nil);
  Fq.Transaction := FTr;

  FqUpdateOperation := TIBSQL.Create(nil);
  FqUpdateOperation.Transaction := FTr;
  FqUpdateOperation.SQL.Text :=
    'UPDATE at_namespace_sync SET operation = :op ' +
    'WHERE namespacekey IS NOT DISTINCT FROM :nk ' +
    '  AND filename IS NOT DISTINCT FROM :fn';
end;

procedure TgdcNamespaceSyncController.Scan;
var
  SL: TStringList;
  I: Integer;
begin
  Init;

  if FUpdateCurrModified then
  begin
    DoLog('���������� ���� ��������� �������...');
    TgdcNamespace.UpdateCurrModified;
  end;

  SL := TStringList.Create;
  try
    if AdvBuildFileList(IncludeTrailingBackslash(FDirectory) + '*.yml',
      faAnyFile, SL, amAny, [flFullNames, flRecursive], '*.*', nil) then
    begin
      for I := 0 to SL.Count - 1 do
      try
        AnalyzeFile(SL[I]);
      except
        on E: Exception do
        begin
          DoLog('������ � �������� ��������� ����� ' + SL[I]);
          DoLog(E.Message);
        end;
      end;
    end;
  finally
    SL.Free;
  end;

  DoLog('����������� �������...');
  FqFillSync.ExecQuery;

  ApplyFilter;

  gd_GlobalParams.NamespacePath := FDirectory;
  DoLog('��������� ��������� � ��������� ' + FDirectory);
end;

procedure TgdcNamespaceSyncController.SetOperation(const AnOp: String);
begin
  Assert(not FDataSet.EOF);

  if
    (
      (AnOp = '<<')
      and
      (FDataSet.FieldByName('fileversion').AsString > '')
    )
    or
    (
      (AnOp = '>>')
      and
      (not FDataSet.FieldByName('namespacekey').IsNull)
    )
    or
    (
      AnOp = '  '
    ) then
  begin
    if FDataSet.FieldByName('namespacekey').IsNull then
      FqUpdateOperation.ParamByName('nk').Clear
    else
      FqUpdateOperation.ParamByName('nk').AsInteger := FDataSet.FieldByName('namespacekey').AsInteger;

    if FDataSet.FieldByName('fileversion').AsString > '' then
      FqUpdateOperation.ParamByName('fn').AsString := FDataSet.FieldByName('filename').AsString
    else
      FqUpdateOperation.ParamByName('fn').Clear;

    FqUpdateOperation.ParamByName('op').AsString := AnOp;
    FqUpdateOperation.ExecQuery;  
  end;
end;

end.
