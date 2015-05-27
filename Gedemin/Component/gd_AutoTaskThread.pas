unit gd_AutoTaskThread;

interface

uses
  Windows, Classes, Controls, Contnrs, SysUtils, gdMessagedThread,
  gdNotifierThread_unit, gd_ProgressNotifier_unit;

type
  TgdTaskLog = class(TObject)
  private
    FId: Integer;
    FAutotaskKey: Integer;
    FEventTime: TDateTime;
    FEventText: String;
    FCreatorKey: Integer;
    FCreationDate: TDateTime;

  public
    property Id: Integer read FId write FId;
    property AutotaskKey: Integer read FAutotaskKey write FAutotaskKey;
    property EventTime: TDateTime read FEventTime write FEventTime;
    property EventText: String read FEventText write FEventText;
    property CreatorKey: Integer read FCreatorKey write FCreatorKey;
    property CreationDate: TDateTime read FCreationDate write FCreationDate;
  end;

  TgdTask = class(TObject)
  private
    FId: Integer;
    FName: String;
    FDescription: String;
    FFunctionKey: Integer;
    FAutoTrKey: Integer;
    FReportKey: Integer;
    FCmdLine: String;
    FBackupFile: String;
    FUserKey: Integer;
    FExactDate: TDateTime;
    FMonthly: Integer;
    FWeekly: Integer;
    FDaily: Boolean;
    FStartTime: TTime;
    FEndTime: TTime;
    FPriority: Integer;
    FDisabled: Boolean;

    FTaskLogList: TObjectList;

    function DayOfTheWeek(const AValue: TDateTime): Word;
    function DayOfTheMonth(const AValue: TDateTime): Word;
    function DaysInMonth(const AValue: TDateTime): Word;
    
    function GetRightTime: Boolean;
    function GetRightUser: Boolean;
    function GetGoodDay: Boolean;
    function GetTaskExecuted: Boolean;

    function GetTaskLog(Index: Integer): TgdTaskLog;
    function GetCount: Integer;

    procedure ExecuteFunction;
    procedure ExecuteAutoTr;
    procedure ExecuteReport;
    procedure ExecuteCmdLine;
    procedure ExecuteBackupFile;

    procedure CheckMissedTasks(AStartDate: TDateTime; AEndDate: TDateTime);
    procedure AddLog(AnEventText: String);

  public
    constructor Create;
    destructor Destroy; override;

    //function Get(AnId: Integer): TgdTaskLog;
    //function Add: TgdTaskLog;
    //procedure Remove(AnId: Integer);

    procedure TaskExecute;

    property RightTime: Boolean read GetRightTime;
    property RightUser: Boolean read GetRightUser;
    property GoodDay: Boolean read GetGoodDay;
    property TaskExecuted: Boolean read GetTaskExecuted;

    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
    property FunctionKey: Integer read FFunctionKey write FFunctionKey;
    property AutoTrKey: Integer read FAutoTrKey write FAutoTrKey;
    property ReportKey: Integer read FReportKey write FReportKey;
    property CmdLine: String read FCmdLine write FCmdLine;
    property BackupFile: String read FBackupFile write FBackupFile;
    property UserKey: Integer read FUserKey write FUserKey;
    property ExactDate: TDateTime read FExactDate write FExactDate;
    property Monthly: Integer read FMonthly write FMonthly;
    property Weekly: Integer read FWeekly write FWeekly;
    property Daily: Boolean read FDaily write FDaily;
    property StartTime: TTime read FStartTime write FStartTime;
    property EndTime: TTime read FEndTime write FEndTime;
    property Priority: Integer read FPriority write FPriority;
    property Disabled: Boolean read FDisabled write FDisabled;

    property Count: Integer read GetCount;
    property TaskLogList[Index: Integer]: TgdTaskLog read GetTaskLog; default;
  end;


  TgdAutoTaskThread = class(TgdMessagedThread)
  private
    FTaskList: TObjectList;
    FTask: TgdTask;
    FNextMsg: Integer;
    FCountWait: Integer;

    function GetCount: Integer;
    function GetTask(Index: Integer): TgdTask;

    procedure LoadFromRelation;
    function FindPriorityTask: TgdTask;

  protected
    procedure Timeout; override;

    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
    procedure Stop;

    property Count: Integer read GetCount;
    property TaskList[Index: Integer]: TgdTask read GetTask; default;
  end;

var
  _gdAutoTaskThread: TgdAutoTaskThread;

  function gdAutoTaskThread: TgdAutoTaskThread;

implementation

uses
  at_classes, gdcBaseInterface, IBSQL, rp_BaseReport_unit, scr_i_FunctionList,
  gd_i_ScriptFactory, ShellApi, gdcAutoTask, gd_security;

const
  WM_GD_FIND_TASK = WM_GD_THREAD_USER + 1;
  WM_GD_EXEC = WM_GD_THREAD_USER + 2;
  WM_GD_CHECK_TIME = WM_GD_THREAD_USER + 3;
  WM_GD_INIT = WM_GD_THREAD_USER + 4;
  WM_GD_LOAD_TASKS = WM_GD_THREAD_USER + 5;
  WM_GD_WAITING = WM_GD_THREAD_USER + 6;

{ TgdTask }

constructor TgdTask.Create;
begin
  inherited;

  FTaskLogList := TObjectList.Create(False);
end;

destructor TgdTask.Destroy;
var
  I: Integer;
begin
  for I := FTaskLogList.Count - 1 downto 0 do
    (FTaskLogList[I] as TgdTaskLog).Free;

  inherited;
end;

{function TgdTask.Get(AnId: Integer): TgdTaskLog;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Self[I].FId = AnId then
    begin
      Result := Self[I];
      exit;
    end;

  raise Exception.Create('Unknown TaskLog')
end;}

{function TgdTask.Add: TgdTaskLog;
var
  I: Integer;
begin
  I := Self.FTaskLogList.Add(TgdTaskLog.Create);
  Result := Self[I];

  if Result = nil then
    raise Exception.Create('Error Creation TaskLog');
end;}

{procedure TgdTask.Remove(AnId: Integer);
var
  I: Integer;
begin
  for I := Self.Count - 1 downto 0 do
    if Self[I].FId = AnId then
    begin
      Self[I].Free;
      Self.FTaskLogList.Delete(I);
      exit;
    end;

  raise Exception.Create('Unknown TaskLog');
end;}

function TgdTask.DayOfTheWeek(const AValue: TDateTime): Word;
begin
  Result := (DateTimeToTimeStamp(AValue).Date - 1) mod 7 + 1;
end;

function TgdTask.DayOfTheMonth(const AValue: TDateTime): Word;
var
  LYear, LMonth: Word;
begin
  DecodeDate(AValue, LYear, LMonth, Result);
end;

function TgdTask.DaysInMonth(const AValue: TDateTime): Word;
var
  LYear, LMonth, LDay: Word;
begin
  DecodeDate(AValue, LYear, LMonth, LDay);
  Result := MonthDays[(LMonth = 2) and IsLeapYear(LYear), LMonth];
end;

function TgdTask.GetRightTime: Boolean;
begin
  if FExactDate <> 0 then
    Result := Now > FExactDate
  else
    Result := (FStartTime < Time) and (Time < FEndTime);
end;

function TgdTask.GetRightUser: Boolean;
begin
  Result := (FUserKey = 0) or (IBLogin.UserKey = FUserKey);
end;

// ��������� ���������� �� ���� ������ ��� ������ ��� ����������.
function TgdTask.GetGoodDay: Boolean;
var
  NDT: TDateTime;
begin
  Result := False;

  NDT := Now;

  if Weekly <> 0 then
    Result := Weekly = DayOfTheWeek(NDT)
  else if (Monthly <> 0) then
  begin
    if (Monthly > 0) then
      Result := Monthly = DayOfTheMonth(NDT)
    else
      Result := (DaysInMonth(NDT) - Monthly + 1) = DayOfTheMonth(NDT);
  end;
end;

// ��������� �� ���� ���� �� ������ ��� ���������.
// ����� ������ � ���� � ���������� ��������� ���������
// ������� � ��� ��� ������ ��� ����������� � �� ���������
function TgdTask.GetTaskExecuted: Boolean;
var
  I: Integer;
  //NDT: TDateTime;
begin
  Result := False;

  //NDT := Now;

  if ExactDate <> 0 then
  begin
    for I := Self.Count - 1 downto 0 do
    begin
      Result := Self[I].EventTime >= ExactDate;
      if Result then
        exit;
    end;
  end
  else
  begin
    for I := Self.Count - 1 downto 0 do
    begin
      Result := Trunc(Self[I].EventTime) = Date;
      if Result then
        exit;
    end;
  end;
end;

function TgdTask.GetTaskLog(Index: Integer): TgdTaskLog;
begin
  Result := Self.FTaskLogList[Index] as TgdTaskLog;
end;

function TgdTask.GetCount: Integer;
begin
  if FTaskLogList <> nil then
    Result := FTaskLogList.Count
  else
    Result := 0;
end;

procedure TgdTask.CheckMissedTasks(AStartDate: TDateTime; AEndDate: TDateTime);
//var
//  I: Integer;
begin
  // �������� �� ����� ���������� ������� ������
  // ���� ��������� ���������� ������ �����
  // ���� �������� ��������������� ���

 //1) ������ "�����-��" ����� ��������� �� ���������� �������� �����
 //2) ������ "�����-��" �� ����� ���� ��������� ��� ��� ����� ������������� �������� ��� ���������
  //'Missed'
  {for I := 0 to gdTaskManager.Count - 1 do
  begin
    if gdTaskManager[I].StartTime <> 0 then
    begin
      if gdTaskManager[I].RightUser and (not gdTaskManager[I].Disabled)
        and gdTaskManager[I].GoodDay
        and (not gdTaskManager[I].TaskExecuted)
        and (gdTaskManager[I].StartTime >= (AStartDate - Trunc(AStartDate)))
        and (gdTaskManager[I].EndTime <= (AEndDate - Trunc(AEndDate))) then
      begin
        gdTaskManager[I].AddLog('Missed');
      end;
     end;
  end;}
end;

procedure TgdTask.AddLog(AnEventText: String);
var
  gdcAutoTaskLog: TgdcAutoTaskLog;
begin
  gdcAutoTaskLog := TgdcAutoTaskLog.Create(nil);
  try
    gdcAutoTaskLog.Open;
    gdcAutoTaskLog.Insert;
    gdcAutoTaskLog.FieldByName('autotaskkey').AsInteger := Self.ID;
    gdcAutoTaskLog.FieldByName('eventtime').AsDateTime := Now;
    gdcAutoTaskLog.FieldByName('eventtext').AsString := AnEventText;
    gdcAutoTaskLog.Post;
  finally
    gdcAutoTaskLog.Free;
  end;
end;

procedure TgdTask.TaskExecute;
var
  SDate: TDateTime;
  EDate: TDateTime;
begin
  SDate := Now;

  if FunctionKey > 0 then
    ExecuteFunction
  else if AutoTrKey > 0 then
    ExecuteAutoTr
  else if ReportKey > 0 then
    ExecuteReport
  else if CmdLine > '' then
    ExecuteCmdLine
  else if BackupFile > '' then
    ExecuteBackupFile;

  EDate := Now;

  CheckMissedTasks(SDate, EDate);
end;

procedure TgdTask.ExecuteFunction;
var
  F: TrpCustomFunction;
  P: Variant;
begin
  AddLog('Started');

  F := glbFunctionList.FindFunction(Self.FFunctionKey);
  if Assigned(F) then
  try
    try
      P := VarArrayOf([]);
      if ScriptFactory.InputParams(F, P) then
        ScriptFactory.ExecuteFunction(F, P);
      AddLog('Done');
    except
      on E: Exception do
      begin
        AddLog(E.Message);
      end;
    end;
  finally
    glbFunctionList.ReleaseFunction(F);
  end;
end;

procedure TgdTask.ExecuteCmdLine;
var
  ExecInfo: TShellExecuteInfo;
begin
  AddLog('Started');

  FillChar(ExecInfo, SizeOf(ExecInfo), 0);
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.Wnd := 0;
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(Self.CmdLine);
  ExecInfo.lpParameters := nil;
  ExecInfo.lpDirectory := nil;
  ExecInfo.nShow := SW_SHOWNORMAL;
  ExecInfo.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;

  if ShellExecuteEx(@ExecInfo) then
    AddLog('Done')
  else
    AddLog(PChar(SysErrorMessage(GetLastError)));
end;

procedure TgdTask.ExecuteAutoTr;
begin
  //////
end;

procedure TgdTask.ExecuteReport;
begin
  //////
end;

procedure TgdTask.ExecuteBackupFile;
begin
  //////
end;

{ TgdAutoTaskThread }

constructor TgdAutoTaskThread.Create;
begin
  inherited Create(True);

  FTaskList := TObjectList.Create(False);

  FreeOnTerminate := False;
  Priority := tpLowest;
end;

destructor TgdAutoTaskThread.Destroy;
var
  I: Integer;
begin
  for I := Self.Count - 1 downto 0 do
  begin
    Self[I].Free;
    FTaskList.Delete(I);
  end;

  FTaskList.Free;

  inherited;
end;

procedure TgdAutoTaskThread.Run;
begin
  Resume;
  PostMsg(WM_GD_INIT);
end;

procedure TgdAutoTaskThread.Stop;
begin

end;

procedure TgdAutoTaskThread.LoadFromRelation;

  procedure LoadLog(ATask: TgdTask);
  var
    q: TIBSQL;
    TaskLog: TgdTaskLog;
  begin
     q := TIBSQL.Create(nil);
     try
       q.Transaction := gdcBaseManager.ReadTransaction;
       q.SQL.Text := 'SELECT * FROM gd_autotask_log WHERE autotaskkey = :autotaskkey';
       q.ParamByName('autotaskkey').AsInteger := ATask.Id;
       q.ExecQuery;

       while not q.EOF do
       begin
         TaskLog := TgdTaskLog.Create;

         TaskLog.Id := q.FieldbyName('id').AsInteger;
         TaskLog.AutotaskKey := q.FieldbyName('autotaskkey').AsInteger;
         TaskLog.EventTime := q.FieldbyName('eventtime').AsDateTime;
         TaskLog.EventText := q.FieldbyName('eventtext').AsString;
         TaskLog.CreatorKey := q.FieldbyName('creatorkey').AsInteger;
         TaskLog.CreationDate := q.FieldbyName('creationdate').AsDateTime;

         ATask.FTaskLogList.Add(TaskLog);

         q.Next;
       end;
     finally
       q.Free;
     end;
  end;

  procedure InitTask(AQ: TIBSQL);
  var
    Task: TgdTask;
  begin
    Task := TgdTask.Create;
    Task.Id := AQ.FieldbyName('id').AsInteger;
    Task.Name := AQ.FieldbyName('name').AsString;
    Task.Description := AQ.FieldbyName('description').AsString;
    Task.FunctionKey := AQ.FieldbyName('functionkey').AsInteger;
    Task.AutoTrKey := AQ.FieldbyName('autotrkey').AsInteger;
    Task.ReportKey := AQ.FieldbyName('reportkey').AsInteger;
    Task.CmdLine := AQ.FieldbyName('cmdline').AsString;
    Task.BackupFile := AQ.FieldbyName('backupfile').AsString;
    Task.UserKey := AQ.FieldbyName('userkey').AsInteger;
    Task.ExactDate := AQ.FieldbyName('exactdate').AsDateTime;
    Task.Monthly := AQ.FieldbyName('monthly').AsInteger;
    Task.Weekly := AQ.FieldbyName('weekly').AsInteger;
    Task.Daily := AQ.FieldbyName('daily').AsInteger = 1;
    Task.StartTime := AQ.FieldbyName('starttime').AsTime;
    Task.EndTime := AQ.FieldbyName('endtime').AsTime;
    Task.Priority := AQ.FieldbyName('priority').AsInteger;
    Task.Disabled := AQ.FieldbyName('disabled').AsInteger = 1;

    LoadLog(Task);

    FTaskList.Add(Task);

  end;

var
  q: TIBSQL;
begin
  Assert(atDatabase <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_autotask';
    q.ExecQuery;

    while not q.EOF do
    begin
      InitTask(q);
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

function TgdAutoTaskThread.FindPriorityTask: TgdTask;
var
  I: Integer;
  NDT: TDateTime;
  MinDT: TDateTime;
begin
  // ��������� �������� ������ � ������� ���������� ��������� �����
  Result := nil;

  if Self.Count = 0 then
    exit;

  NDT := Now;

  MinDT := 0;

  for I := 0 to Self.Count - 1 do
  begin
    if Self[I].ExactDate <> 0 then
    begin
      if Self[I].RightUser and (not Self[I].Disabled)
        and (not Self[I].TaskExecuted) then
      begin
        if (MinDT > Self[I].ExactDate)
          or (MinDT = 0) then
        begin
          MinDT := Self[I].ExactDate;
          Result := Self[I];
        end;
      end;
    end
    else if Self[I].StartTime <> 0 then
    begin
      if Self[I].RightUser and (not Self[I].Disabled)
        and Self[I].GoodDay
        and (not Self[I].TaskExecuted) then
      begin
        if (MinDT > (Trunc(NDT) + Self[I].StartTime))
          or (MinDT = 0) then
        begin
          MinDT := Trunc(NDT) + Self[I].StartTime;
          Result := Self[I];
        end;
      end;
    end
    else
      raise Exception.Create('invalid task');
  end;
end;

function TgdAutoTaskThread.GetCount: Integer;
begin
  if Self.FTaskList <> nil then
    Result := Self.FTaskList.Count
  else
    Result := 0;
end;

function TgdAutoTaskThread.GetTask(Index: Integer): TgdTask;
begin
  Result := Self.FTaskList[Index] as TgdTask;
end;

procedure TgdAutoTaskThread.Timeout;
begin
  if FNextMsg > 0 then
  begin
    PostMsg(FNextMsg);
    FNextMsg := 0;
  end;
end;

function TgdAutoTaskThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of
    WM_GD_INIT:
    begin
      FCountWait := 0;
      SetTimeout(1);
      FNextMsg := WM_GD_WAITING;
      gdNotifierThread.Add('����������� �������: �������')
    end;

    WM_GD_WAITING:
    begin
      if FCountWait < 5 then
      begin
        SetTimeout(10000);
        FNextMsg := WM_GD_WAITING;
        Inc(FCountWait);
      end
      else
      begin
        SetTimeout(1);
        FNextMsg := WM_GD_LOAD_TASKS;
      end;
    end;

    WM_GD_LOAD_TASKS:
    begin
      LoadFromRelation;
      SetTimeout(1);
      FNextMsg := WM_GD_FIND_TASK;
    end;

    WM_GD_FIND_TASK:
    begin
      FTask := FindPriorityTask;
      if FTask = nil then
      begin
        gdNotifierThread.Add('����������� �������: ��� �������� �����');
        ExitThread;
        gdNotifierThread.Add('����������� �������: ����������');
      end
      else
      begin
        SetTimeout(1);
        FNextMsg := WM_GD_CHECK_TIME;
      end;
    end;

    WM_GD_EXEC:
    begin
      gdNotifierThread.Add('����������� �������: ���������� ' + FTask.Name);
      Synchronize(FTask.TaskExecute);
      SetTimeout(1);
      FNextMsg := WM_GD_FIND_TASK;
    end;

    WM_GD_CHECK_TIME:
    begin
      if FTask.RightTime then
      begin
        SetTimeout(1);
        FNextMsg := WM_GD_EXEC;
      end
      else
      begin
        SetTimeout(30000);
        FNextMsg := WM_GD_CHECK_TIME;
      end;
    end

  else
    Result := False;
  end;
end;

function gdAutoTaskThread: TgdAutoTaskThread;
begin
  if not Assigned(_gdAutoTaskThread) then
    _gdAutoTaskThread := TgdAutoTaskThread.Create;
  Result := _gdAutoTaskThread;
end;

initialization
  _gdAutoTaskThread := nil;

finalization
  FreeAndNil(_gdAutoTaskThread);

end.