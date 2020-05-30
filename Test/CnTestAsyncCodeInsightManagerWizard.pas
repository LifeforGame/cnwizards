{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestAsyncCodeInsightManagerWizard;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestAsyncCodeInsightManagerWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��ֻ֧�� D10.4 �����ϰ汾�������첽 CodeInsightManager ��
* ����ƽ̨��Windows 10 + Delphi 10.4
* ���ݲ��ԣ�
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2020.05.30 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTestAsyncCodeInsightManagerWizard �˵�ר��
//==============================================================================

{ TCnTestAsyncCodeInsightManagerWizard }

  TCnTestAsyncCodeInsightManagerWizard = class(TCnMenuWizard)
  private
    procedure AsyncCodeCompletionCallBack(Sender: TObject; AId: Integer;
      AError: Boolean; const AMessage: string);
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// CnTestAsyncCodeInsightManagerWizard �˵�ר��
//==============================================================================

{ TCnTestAsyncCodeInsightManagerWizard }

procedure TCnTestAsyncCodeInsightManagerWizard.AsyncCodeCompletionCallBack(
  Sender: TObject; AId: Integer; AError: Boolean; const AMessage: string);
begin
  ShowMessage(Format('CallBack AId: %d. Error %d. Message %s',
    [AId, Integer(AError), AMessage]));
end;

procedure TCnTestAsyncCodeInsightManagerWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestAsyncCodeInsightManagerWizard.Execute;
var
  I: Integer;
  Str: string;
  Allow: Boolean;
  View: IOTAEditView;
  CIS: IOTACodeInsightServices;
  CIM: IOTACodeInsightManager;
  ACIM: IOTAAsyncCodeInsightManager;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  CIS := (BorlandIDEServices as IOTACodeInsightServices);
  for I := 0 to CIS.CodeInsightManagerCount - 1 do
  begin
    CIM := CIS.CodeInsightManager[I];
    if CIM = nil then
      Continue;

    CnDebugger.LogFmt('CodeInsightManager: %d. Enabled: %d - %s - %s',
      [I, Integer(CIM.Enabled), CIM.GetIDString, CIM.Name]);

    if not CIM.Enabled then
      Continue;

    if Supports(CIM, IOTAAsyncCodeInsightManager, ACIM) then
    begin
      CnDebugger.LogFmt('CodeInsightManager: %d Is Async.', [I]);

      // �����첽����
      ACIM.AsyncAllowCodeInsight(Allow, #0);
      if not Allow then
      begin
        ShowMessage('NOT Allow.');
        Continue;
      end;

      if not ACIM.AsyncCanInvoke(citCodeInsight) then
      begin
        ShowMessage('Can NOT Invoke');
        Continue;
      end;

      Str := '';
      ACIM.AsyncInvokeCodeCompletion(itManual, Str, View.CursorPos.Line,
        View.CursorPos.Col, AsyncCodeCompletionCallBack);
      CnDebugger.LogMsg('AsyncInvokeCodeCompletion Called.');
    end;
  end;
end;

function TCnTestAsyncCodeInsightManagerWizard.GetCaption: string;
begin
  Result := 'Test Async CodeInsightManager';
end;

function TCnTestAsyncCodeInsightManagerWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestAsyncCodeInsightManagerWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestAsyncCodeInsightManagerWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestAsyncCodeInsightManagerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestAsyncCodeInsightManagerWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Async CodeInsightManager Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Async CodeInsightManager for LSP';
end;

procedure TCnTestAsyncCodeInsightManagerWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestAsyncCodeInsightManagerWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestAsyncCodeInsightManagerWizard); // ע��˲���ר��

end.