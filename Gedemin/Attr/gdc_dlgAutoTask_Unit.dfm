inherited gdc_dlgAutoTask: Tgdc_dlgAutoTask
  Left = 663
  Top = 120
  Caption = 'gdc_dlgAutoTask'
  ClientHeight = 548
  ClientWidth = 440
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbPriority: TLabel [0]
    Left = 8
    Top = 494
    Width = 371
    Height = 13
    Caption = 
      '���������� ����� ���������� ��� �����, ����������� �� ���� �����' +
      ':'
  end
  object Label2: TLabel [1]
    Left = 9
    Top = 240
    Width = 419
    Height = 27
    AutoSize = False
    Caption = 
      '�������� ���� ������� ��� ���������� ��� ����� ������� ������� �' +
      '/��� �� ����� ����������. ��� �������� ���������� ����������� IP' +
      ' ����� ��� ���.'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object lbStartTime: TLabel [2]
    Left = 9
    Top = 432
    Width = 64
    Height = 13
    Caption = '��������� �'
  end
  object lbEndTime: TLabel [3]
    Left = 143
    Top = 432
    Width = 13
    Height = 13
    Caption = '��'
  end
  object Label4: TLabel [4]
    Left = 79
    Top = 454
    Width = 313
    Height = 13
    Caption = '�������� ���� ������� ��� ���������� � ����� ����� ���.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbName: TLabel [5]
    Left = 8
    Top = 13
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object lbDescription: TLabel [6]
    Left = 8
    Top = 35
    Width = 53
    Height = 13
    Caption = '��������:'
  end
  object lbUser: TLabel [7]
    Left = 8
    Top = 196
    Width = 212
    Height = 13
    Caption = '��������� ������ ��� ������� �������:'
  end
  object Label8: TLabel [8]
    Left = 8
    Top = 220
    Width = 180
    Height = 13
    Caption = '��������� ������ �� ����������:'
  end
  object Label9: TLabel [9]
    Left = 8
    Top = 473
    Width = 354
    Height = 13
    Caption = 
      '��������� ���������� ������                  ������ (0 -- �� ���' +
      '������)'
  end
  inherited btnAccess: TButton
    Left = 7
    Top = 519
    TabOrder = 17
  end
  inherited btnNew: TButton
    Left = 79
    Top = 519
    TabOrder = 18
  end
  inherited btnHelp: TButton
    Left = 151
    Top = 519
    TabOrder = 19
  end
  inherited btnOK: TButton
    Left = 290
    Top = 519
    TabOrder = 15
  end
  inherited btnCancel: TButton
    Left = 362
    Top = 519
    TabOrder = 16
  end
  object gbTimeTables: TGroupBox [15]
    Left = 6
    Top = 271
    Width = 425
    Height = 155
    Caption = ' ���������� '
    TabOrder = 9
    object Label3: TLabel
      Left = 26
      Top = 77
      Width = 324
      Height = 13
      Caption = '������������� �������� ������ ������ ���� � ����� ������.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 27
      Top = 93
      Width = 249
      Height = 13
      Caption = '-1 -- ��������� ����, -2 -- ������������� � �.�.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 273
      Top = 114
      Width = 124
      Height = 13
      Caption = '1 -- ��, 2 -- ��, ... 7 -- ��'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object rbExactDate: TRadioButton
      Left = 8
      Top = 34
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 1
    end
    object xdbeExactDate: TxDateDBEdit
      Left = 200
      Top = 34
      Width = 65
      Height = 21
      DataField = 'exactdate'
      DataSource = dsgdcBase
      Kind = kDate
      EmptyAtStart = True
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 2
    end
    object rbMonthly: TRadioButton
      Left = 8
      Top = 55
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 3
    end
    object rbWeekly: TRadioButton
      Left = 8
      Top = 111
      Width = 193
      Height = 21
      Caption = '����������� � ��������� ����:'
      TabOrder = 5
    end
    object dbcbWeekly: TDBComboBox
      Left = 200
      Top = 111
      Width = 65
      Height = 21
      Style = csDropDownList
      DataField = 'weekly'
      DataSource = dsgdcBase
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7')
      TabOrder = 6
    end
    object rbDaily: TRadioButton
      Left = 8
      Top = 133
      Width = 89
      Height = 17
      Caption = '���������'
      TabOrder = 7
    end
    object dbcbMonthly: TDBComboBox
      Left = 200
      Top = 57
      Width = 65
      Height = 21
      DataField = 'MONTHLY'
      DataSource = dsgdcBase
      DropDownCount = 16
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20'
        '21'
        '22'
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '-1'
        '-2'
        '-3'
        '-4'
        '-5'
        '-6'
        '-7'
        '-8'
        '-9'
        '-10'
        '-11'
        '-12'
        '-13'
        '-14'
        '-15'
        '-16'
        '-17'
        '-18'
        '-19'
        '-20'
        '-21'
        '-22'
        '-23'
        '-24'
        '-25'
        '-26'
        '-27'
        '-28'
        '-29'
        '-30'
        '-31')
      TabOrder = 4
    end
    object rbAtStartup: TRadioButton
      Left = 8
      Top = 16
      Width = 201
      Height = 17
      Caption = '��� ������� �������'
      TabOrder = 0
    end
  end
  object dbcbPriority: TDBComboBox [16]
    Left = 384
    Top = 491
    Width = 48
    Height = 21
    DataField = 'PRIORITY'
    DataSource = dsgdcBase
    ItemHeight = 13
    Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9')
    TabOrder = 14
  end
  object xdbeStartTime: TxDateDBEdit [17]
    Left = 79
    Top = 430
    Width = 57
    Height = 21
    DataField = 'starttime'
    DataSource = dsgdcBase
    Kind = kTime
    EmptyAtStart = True
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 10
  end
  object xdbeEndTime: TxDateDBEdit [18]
    Left = 162
    Top = 430
    Width = 57
    Height = 21
    DataField = 'endtime'
    DataSource = dsgdcBase
    Kind = kTime
    EmptyAtStart = True
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 11
  end
  object btnClearTime: TButton [19]
    Left = 230
    Top = 429
    Width = 75
    Height = 21
    Caption = '��������'
    TabOrder = 12
    OnClick = btnClearTimeClick
  end
  object dbcbDisabled: TDBCheckBox [20]
    Left = 351
    Top = 35
    Width = 80
    Height = 17
    Caption = '���������'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbedName: TDBEdit [21]
    Left = 99
    Top = 10
    Width = 246
    Height = 21
    Anchors = []
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [22]
    Left = 99
    Top = 35
    Width = 246
    Height = 33
    Anchors = []
    DataField = 'Description'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object pcTask: TPageControl [23]
    Left = 8
    Top = 72
    Width = 421
    Height = 115
    ActivePage = tsReport
    Anchors = []
    MultiLine = True
    TabOrder = 4
    object tsFunction: TTabSheet
      Caption = '������-�������'
      object iblkupFunction: TgsIBLookupComboBox
        Left = 8
        Top = 5
        Width = 400
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'FUNCTIONKEY'
        ListTable = 'GD_FUNCTION'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcFunction'
        Anchors = []
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
    object tsCmd: TTabSheet
      Caption = '������� ���������'
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 34
        Width = 368
        Height = 33
        AutoSize = False
        Caption = '������� ��� ��������� (�������) � ��������� ��������� ������.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object dbeCmdLine: TDBEdit
        Left = 8
        Top = 5
        Width = 373
        Height = 21
        Anchors = []
        DataField = 'cmdline'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btnCmdLine: TButton
        Left = 381
        Top = 4
        Width = 25
        Height = 21
        Anchors = []
        Caption = '...'
        TabOrder = 1
        OnClick = btnCmdLineClick
      end
    end
    object tsBackup: TTabSheet
      Caption = '�������������'
      ImageIndex = 2
      object Label7: TLabel
        Left = 9
        Top = 36
        Width = 397
        Height = 57
        AutoSize = False
        Caption = 
          '����������� �������������� [YYYY], [MM], [DD], [HH], [NN], [SS] ' +
          '��� ����������� � ��� ����� ������� �������� ����, ������, ���, ' +
          '����, ������ � ������, ��������������.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object dbeBackup: TDBEdit
        Left = 8
        Top = 8
        Width = 303
        Height = 21
        DataField = 'backupfile'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btBackup: TButton
        Left = 312
        Top = 7
        Width = 94
        Height = 21
        Caption = '������������'
        TabOrder = 1
        OnClick = btBackupClick
      end
    end
    object tsReport: TTabSheet
      Caption = '�����'
      ImageIndex = 3
      object Label10: TLabel
        Left = 0
        Top = 8
        Width = 36
        Height = 13
        Caption = '�����:'
      end
      object Label11: TLabel
        Left = 0
        Top = 32
        Width = 40
        Height = 13
        Caption = '������:'
      end
      object Label12: TLabel
        Left = 0
        Top = 64
        Width = 30
        Height = 13
        Caption = 'SMTP:'
      end
      object Label13: TLabel
        Left = 120
        Top = 8
        Width = 58
        Height = 13
        Caption = '��� �����:'
      end
      object Label14: TLabel
        Left = 120
        Top = 32
        Width = 57
        Height = 13
        Caption = '��� �����:'
      end
      object Label15: TLabel
        Left = 120
        Top = 56
        Width = 57
        Height = 13
        Caption = '���������:'
      end
      object Label16: TLabel
        Left = 288
        Top = 8
        Width = 71
        Height = 13
        Caption = '����� ������:'
      end
      object iblkupReportKey: TgsIBLookupComboBox
        Left = 40
        Top = 8
        Width = 73
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'REPORTKEY'
        ListTable = 'RP_REPORTLIST'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 13
        TabOrder = 0
      end
      object iblkupGroupKey: TgsIBLookupComboBox
        Left = 40
        Top = 32
        Width = 73
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'GROUPKEY'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'GD_CONTACT.CONTACTTYPE  =  1'
        gdClassName = 'TgdcGroup'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object iblkupSMTPKey: TgsIBLookupComboBox
        Left = 40
        Top = 56
        Width = 73
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'SMTPKEY'
        ListTable = 'GD_SMTP'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcSMTP'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object dbeFileName: TDBEdit
        Left = 184
        Top = 8
        Width = 89
        Height = 21
        DataField = 'FILENAME'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbeMsgSubject: TDBEdit
        Left = 184
        Top = 56
        Width = 89
        Height = 21
        DataField = 'MSGSUBJECT'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbmMsgBody: TDBMemo
        Left = 288
        Top = 32
        Width = 121
        Height = 41
        DataField = 'MSGBODY'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbcbExportType: TDBComboBox
        Left = 184
        Top = 32
        Width = 89
        Height = 21
        DataField = 'EXPORTTYPE'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          'WORD'
          'EXCEL'
          'PDF'
          'XML')
        TabOrder = 6
      end
    end
  end
  object iblkupUser: TgsIBLookupComboBox [24]
    Left = 222
    Top = 193
    Width = 208
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'USERKEY'
    ListTable = 'GD_USER'
    ListField = 'NAME'
    KeyField = 'ID'
    gdClassName = 'TgdcUser'
    Anchors = []
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  object btExecTask: TButton [25]
    Left = 352
    Top = 9
    Width = 75
    Height = 21
    Action = actExecTask
    TabOrder = 2
  end
  object dbedComputer: TDBEdit [26]
    Left = 222
    Top = 218
    Width = 136
    Height = 21
    Anchors = []
    DataField = 'COMPUTER'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  object btnIP: TButton [27]
    Left = 358
    Top = 218
    Width = 35
    Height = 21
    Caption = 'IP'
    TabOrder = 7
    OnClick = btnIPClick
  end
  object btnCN: TButton [28]
    Left = 393
    Top = 218
    Width = 35
    Height = 21
    Caption = '���'
    TabOrder = 8
    OnClick = btnCNClick
  end
  object dbedPulse: TDBEdit [29]
    Left = 177
    Top = 470
    Width = 43
    Height = 21
    Anchors = []
    DataField = 'PULSE'
    DataSource = dsgdcBase
    TabOrder = 13
  end
  inherited alBase: TActionList
    Left = 238
    Top = 492
    object actExecTask: TAction
      Caption = '���������'
      OnExecute = actExecTaskExecute
      OnUpdate = actExecTaskUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 200
    Top = 492
  end
  inherited pm_dlgG: TPopupMenu
    Left = 272
    Top = 493
  end
  inherited ibtrCommon: TIBTransaction
    Left = 312
    Top = 493
  end
  object odCmdLine: TOpenDialog
    Filter = 
      '����������� ����� *.exe|*.exe|�������� ����� *.bat|*.bat|��� ���' +
      '�� *.*|*.*'
    Title = '����� �����'
    Left = 352
    Top = 489
  end
end
