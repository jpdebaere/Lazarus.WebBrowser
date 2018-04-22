unit WebBrowserCtrls;

{$i webbrowser.inc}

interface

uses
  Classes, SysUtils, Graphics, Controls, Forms, Dialogs,
  WebSystem, WebBrowserIntf;

{ TCustomWebControl }

type
  TWebBrowser = class;

  TCustomWebControl = class(TCustomControl, IWebBrowserEvents)
  private
    FWebBrowser: TWebBrowser;
    procedure SetWebBrowser(Value: TWebBrowser);
  protected
    { IWebBrowserEvents }
    procedure DoError(const Uri: string; ErrorCode: LongWord; const ErrorMessage: string; var Handled: Boolean); virtual;
    procedure DoReady; virtual;
    procedure DoRequest(var Uri: string); virtual;
    procedure DoContextMenu(X, Y: Integer; HitTest: TWebHitTest; const Link, Media: string; var Handled: Boolean); virtual;
    procedure DoHitTest(X, Y: Integer; HitTest: TWebHitTest; const Link, Media: string); virtual;
    procedure DoLoadStatusChange; virtual;
    procedure DoLocationChange; virtual;
    procedure DoNavigate(const Uri: string; var Action: TWebNavigateAction); virtual;
    procedure DoProgress(Progress: Integer); virtual;
    procedure DoFavicon(Icon: TGraphic); virtual;
    procedure DoConsoleMessage(const Message, Source: string; Line: Integer); virtual;
    procedure DoScriptDialog(Dialog: TWebScriptDialog; const Message: string;
      var Input: string; var Accepted: Boolean; var Handled: Boolean); virtual;
    { TCustomWebControl normal methods }
    procedure BrowserChange(Browser: TWebBrowser; Connect: Boolean); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { WebBrowser is used by custom web controls to communicate with a browser }
    property WebBrowser: TWebBrowser read FWebBrowser write SetWebBrowser;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TWebInspector }

  TWebInspector = class(TCustomWebControl, IWebInspectorControl)
  private
    FWidget: IWebInspector;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean);
  protected
    { IWebInspectorControl }
    function GetWidget: IWebInspector;
    property Widget: IWebInspector read GetWidget;
    { TWebInspector normal methods }
    procedure BrowserChange(Browser: TWebBrowser; Connect: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    { When active is true this window will show inspector controls
      if an associated WebBrowser property is valid }
    property Active: Boolean read GetActive write SetActive;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Enabled;
    property WebBrowser;
  end;

{ Error events allow you to errors that occur during a request.
  Set Handled to True to prevent the default action. }
  TWebErrorEvent = procedure(Sender: TObject; const Uri: string; ErrorCode: LongWord;
    const ErrorMessage: string; var Handled: Boolean) of object;
{ Hit testing allows you to determine the content under the mouse.
  Set Handled to True to prevent the default action. }
  TWebContextMenuEvent = procedure(Sender: TObject; X, Y: Integer;
    HitTest: TWebHitTest; const Link, Media: string; var Handled: Boolean) of object;
{ Hit testing allows you to determine the element under the mouse.
  Link refers to the Uri under the mouse, and Media refers to the element source. }
  TWebHitTestEvent = procedure(Sender: TObject; X, Y: Integer;
    HitTest: TWebHitTest; const Link, Media: string) of object;
{ Before a uri can be navigated you can allow or deny it access.
  Set action to alter the access. }
  TWebNavigateEvent = procedure(Sender: TObject; const Uri: string;
    var Action: TWebNavigateAction) of object;
{ Progress ranges from 0 to 100 in terms of a percentage of completion }
  TWebProgressEvent = procedure(Sender: TObject; Progress: Integer) of object;
{ Before every request made you can examine and optionally alter the Uri }
  TWebRequestEvent = procedure(Sender: TObject; var Uri: string) of object;
{ The console event provides access to console messages and optionally
  error source and line if generated by an error }
  TWebConsoleEvent = procedure(Sender: TObject; const Message, Source: string;
    Line: Integer) of object;
  { Script dialog events are genreated by javascript on page. The actual dialog
    is generated by the default handler of TCustomWebBrowser, but you can
    override that functionality }
  TWebScriptDialogEvent = procedure(Sender: TObject;
    { The dialog type, ether alert, confirm, or prompt }
    Dialog: TWebScriptDialog;
    { The message displayed in the body of the dialog }
    const Message: string;
    { For prompt dialogs this should be used for the default value and result value }
    var Input: string;
    { Set accepted to True if the user clicks OK to close the dialog }
    var Accepted: Boolean;
    { Set handled to True to prevent the default dialog handler }
    var Handled: Boolean) of object;

{ TCustomWebBrowser is an embeddable web browser control }

  TCustomWebBrowser = class(TCustomWebControl, IWebBrowserControl)
  private
    FWidget: IWebBrowser;
    FUri: string;
    FHtml: string;
    FHtmlDefined: Boolean;
    FLoadStatus: TWebLoadStatus;
    FFavicon: TGraphic;
    FReady: Boolean;
    FOnError: TWebErrorEvent;
    FOnContextMenu: TWebContextMenuEvent;
    FOnHitTest: TWebHitTestEvent;
    FOnLoadStatusChange: TNotifyEvent;
    FOnLocationChange: TNotifyEvent;
    FOnNavigate: TWebNavigateEvent;
    FOnProgress: TWebProgressEvent;
    FOnRequest: TWebRequestEvent;
    FOnFavicon: TNotifyEvent;
    FOnConsoleMessage: TWebConsoleEvent;
    FOnScriptDialog: TWebScriptDialogEvent;
    FEvents: TArrayList<IWebBrowserEvents>;
    function GetDesignMode: Boolean;
   procedure PropHtmlDefinedRead(Reader: TReader);
    procedure PropHtmlDefinedWrite(Writer: TWriter);
    procedure PropHtmlRead(Reader: TReader);
    procedure PropHtmlWrite(Writer: TWriter);
    procedure SetDesignMode(Value: Boolean);
    procedure SetLocation(const Value: string);
    function GetSourceView: Boolean;
    procedure SetSourceView(Value: Boolean);
    function GetLoadStatus: TWebLoadStatus;
    function GetTitle: string;
    function GetZoomContent: Boolean;
    procedure SetZoomContent(Value: Boolean);
    function GetZoomFactor: Single;
    procedure SetZoomFactor(Value: Single);
  protected
    { IWebBrowserControl }
    function GetWidget: IWebBrowser;
    function GetEvents: IWebBrowserEvents;
    procedure AddNotification(Notify: IWebBrowserEvents);
    procedure RemoveNotification(Notify: IWebBrowserEvents);
    { IWebBrowserEvents }
    procedure DoError(const Uri: string; ErrorCode: LongWord; const ErrorMessage: string;
        var Handled: Boolean); override;
    procedure DoReady; override;
    procedure DoRequest(var Uri: string); override;
    procedure DoContextMenu(X, Y: Integer; HitTest: TWebHitTest; const Link, Media: string;
      var Handled: Boolean); override;
    procedure DoHitTest(X, Y: Integer; HitTest: TWebHitTest; const Link, Media: string); override;
    procedure DoLoadStatusChange; override;
    procedure DoLocationChange; override;
    procedure DoNavigate(const Uri: string; var Action: TWebNavigateAction); override;
    procedure DoProgress(Progress: Integer); override;
    procedure DoFavicon(Icon: TGraphic); override;
    procedure DoConsoleMessage(const Message, Source: string; Line: Integer); override;
    procedure DoScriptDialog(Dialog: TWebScriptDialog; const Message: string;
      var Input: string; var Accepted: Boolean; var Handled: Boolean); override;
    { Normal methods }
    procedure DefineProperties(Filer: TFiler); override;
    property WebBrowser: IWebBrowser read GetWidget;
    { Favicon represents the icon for the current page }
    property Favicon: TGraphic read FFavicon;
    { The uri of the content being displayed }
    property Location: string read FUri write SetLocation;
    { When DesignMode is true the page can be edited by the user }
    property DesignMode: Boolean read GetDesignMode write SetDesignMode;
    { When SourceView is true raw content is shown rather than visual layouts }
    property SourceView: Boolean read GetSourceView write SetSourceView;
    { The status of a navigation request }
    property LoadStatus: TWebLoadStatus read GetLoadStatus;
    { The title string extracted from a web page }
    property Title: string read GetTitle;
    { When ZoomContent is false only text is resized by zoom factor }
    property ZoomContent: Boolean read GetZoomContent write SetZoomContent;
    { ZoomFactor can be used to increase or decrease the size of text or content  }
    property ZoomFactor: Single read GetZoomFactor write SetZoomFactor;
    { OnHitTest is invoked when the mouse moves over the control }
    property OnError: TWebErrorEvent read FOnError write FOnError;
    { OnContextMenu is invoked when a context menu is about to be shown }
    property OnContextMenu: TWebContextMenuEvent read FOnContextMenu write FOnContextMenu;
    { OnHitTest is invoked when the mouse moves over the control }
    property OnHitTest: TWebHitTestEvent read FOnHitTest write FOnHitTest;
    { OnLoadStatusChange occurs when the main frame ladong status changes }
    property OnLoadStatusChange: TNotifyEvent read FOnLoadStatusChange write FOnLoadStatusChange;
    { OnLocationChange occurs when a new uri begins to load or is redirected }
    property OnLocationChange: TNotifyEvent read FOnLocationChange write FOnLocationChange;
    { OnNavigate is invoked before every request is made }
    property OnNavigate: TWebNavigateEvent read FOnNavigate write FOnNavigate;
    { OnProgress is invoked with each response from a request }
    property OnProgress: TWebProgressEvent read FOnProgress write FOnProgress;
    { OnProgress is invoked before every request }
    property OnRequest: TWebRequestEvent read FOnRequest write FOnRequest;
    { OnFavicon is invoked for every page load, sometimes with an empty graphic }
    property OnFavicon: TNotifyEvent read FOnFavicon write FOnFavicon;
    { OnConsoleMessage is invoked by javascript console.log() or page errors }
    property OnConsoleMessage: TWebConsoleEvent read FOnConsoleMessage write FOnConsoleMessage;
    { OnScriptDialog is invoked by javascript alert(), confirm(), and prompt() functions }
    property OnScriptDialog: TWebScriptDialogEvent read FOnScriptDialog write FOnScriptDialog;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Load content by navigating using a protocol such as http: file: or about: }
    procedure Load(const Uri: string);
    { Load content directly from an html string }
    procedure LoadHtml(const Html: string);
    { Stop a load navigate request }
    procedure Stop;
    { Repeat the previously navigated uri request or html load }
    procedure Reload;
    { Insert a snippet of javascript into the page and execute it }
    procedure ExecuteScript(Script: string);
    { Capture an image of the current web page }
    function Snapshot: TGraphic;
    { Navigate back (negative) or forward (positive) a number of steps in history }
    procedure BackOrForward(Steps: Integer);
    { Query if it's possible to navigate back or forward a number of steps in history }
    function BackOrForwardExists(Steps: Integer): Boolean;
    { Html stores the last value passed to LoadHtml. Use the "Edit" verb from the
      component  editor to set this property at design time. }
    property Html: string read FHtml;
    { HtmlDefined is true when the last load method invoked was LoadHtml }
    property HtmlDefined: Boolean read FHtmlDefined;
  end;

{ TWebBrowser }

  TWebBrowser = class(TCustomWebBrowser)
  public
    property Favicon;
    property LoadStatus;
    property Title;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Enabled;
    property Location;
    property DesignMode;
    property SourceView;
    property Visible;
    property ZoomContent;
    property ZoomFactor;
    property OnConsoleMessage;
    property OnContextMenu;
    property OnScriptDialog;
    property OnError;
    property OnFavicon;
    property OnHitTest;
    property OnLoadStatusChange;
    property OnLocationChange;
    property OnNavigate;
    property OnProgress;
    property OnRequest;
  end;

function WebControlsAvaiable: Boolean;

implementation

{$ifdef lclgtkall}
  {$ifdef lclgtk2}
  uses
    WebBrowserGtk2, WSLCLClasses;

  function WebControlsAvaiable: Boolean;
  begin
    Result := WebBrowserGtk2.WebControlsAvaiable;
  end;
  {$endif}

  {$ifdef lclgtk3}
  uses
    WebBrowserGtk3, WSLCLClasses;

  function WebBrowserAvaiable: Boolean;
  begin
    Result := WebBrowserGtk3.WebBrowserAvaiable;
  end;
  {$endif}
{$else}
uses
  WSLCLClasses;

function WebBrowserAvaiable: Boolean;
begin
  Result := False;
end;

function WebBrowserNew(Control: IWebBrowserControl): IWebBrowser;
begin
  Result := nil;
end;

function WebBrowserWSClass: TWSLCLComponentClass;
begin
  Result := nil;
end;
{$endif}

{ TCustomWebControl }


constructor TCustomWebControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TCustomWebControl.Destroy;
begin
  WebBrowser := nil;
  inherited Destroy;
end;

procedure TCustomWebControl.BrowserChange(Browser: TWebBrowser; Connect: Boolean);
begin
  if ClassType = TCustomWebBrowser then
    Exit;
  if Connect then
    Browser.AddNotification(Self)
  else
    Browser.RemoveNotification(Self);
end;

procedure TCustomWebControl.SetWebBrowser(Value: TWebBrowser);
begin
  if ClassType = TCustomWebBrowser then
    Exit;
  if Value = FWebBrowser then
    Exit;
  if FWebBrowser <> nil then
  begin
    FWebBrowser.RemoveFreeNotification(Self);
    BrowserChange(FWebBrowser, False);
  end;
  FWebBrowser := Value;
  if FWebBrowser <> nil then
  begin
    FWebBrowser.FreeNotification(Self);
    BrowserChange(FWebBrowser, True);
  end;
end;

procedure TCustomWebControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if AComponent = FWebBrowser then
  begin
    BrowserChange(FWebBrowser, False);
    FWebBrowser := nil;
  end;
end;

{ TCustomWebControl.IWebBrowserEvents }

procedure TCustomWebControl.DoError(const Uri: string; ErrorCode: LongWord;
  const ErrorMessage: string; var Handled: Boolean);
begin
end;

procedure TCustomWebControl.DoReady;
begin
end;

procedure TCustomWebControl.DoRequest(var Uri: string);
begin
end;

procedure TCustomWebControl.DoContextMenu(X, Y: Integer; HitTest: TWebHitTest;
  const Link, Media: string; var Handled: Boolean);
begin
end;

procedure TCustomWebControl.DoHitTest(X, Y: Integer; HitTest: TWebHitTest;
  const Link, Media: string);
begin
end;

procedure TCustomWebControl.DoLoadStatusChange;
begin
end;

procedure TCustomWebControl.DoLocationChange;
begin
end;

procedure TCustomWebControl.DoNavigate(const Uri: string;
  var Action: TWebNavigateAction);
begin
end;

procedure TCustomWebControl.DoProgress(Progress: Integer);
begin
end;

procedure TCustomWebControl.DoFavicon(Icon: TGraphic);
begin
end;

procedure TCustomWebControl.DoConsoleMessage(const Message, Source: string; Line: Integer);
begin
end;

procedure TCustomWebControl.DoScriptDialog(Dialog: TWebScriptDialog;
  const Message: string; var Input: string; var Accepted: Boolean;
  var Handled: Boolean);
begin
end;

{ TWebInspector }

constructor TWebInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 400;
  Height := 200;
  FWidget := WebInspectorNew(Self);
end;

procedure TWebInspector.BrowserChange(Browser: TWebBrowser; Connect: Boolean);
begin
  inherited BrowserChange(Browser, Connect);
  if Connect then
    Widget.Connect(Browser.GetWidget)
  else
    Widget.Connect(nil);
end;

{ TWebInspector.IWebInspectorControl }

function TWebInspector.GetWidget: IWebInspector;
begin
  Result := FWidget;
end;

function TWebInspector.GetActive: Boolean;
begin
  Result := FWidget.Active;
end;

procedure TWebInspector.SetActive(Value: Boolean);
begin
  FWidget.Active := Value;
end;

{ TCustomWebBrowser }

constructor TCustomWebBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 400;
  Height := 400;
  FLoadStatus := lsFailed;
  FWidget := WebBrowserNew(Self);
  FFavicon := TBitmap.Create;
  FUri := 'about:blank';
  FHtml :=
    '<html>'#10 +
    '<body>'#10 +
    '  <h1>Hello World</h1>'#10 +
    '  <div>This is some raw html</div>'#10 +
    '</body>'#10 +
    '</html>';
end;

destructor TCustomWebBrowser.Destroy;
begin
  FFavicon.Free;
  inherited Destroy;
end;

{ TCustomWebBrowser.IWebBrowserControl }

function TCustomWebBrowser.GetWidget: IWebBrowser;
begin
  Result := FWidget;
end;

function TCustomWebBrowser.GetEvents: IWebBrowserEvents;
begin
  Result := Self;
end;

procedure TCustomWebBrowser.AddNotification(Notify: IWebBrowserEvents);
begin
  if Notify is IWebBrowserControl then
    Exit;
  FEvents.Push(Notify);
end;

procedure TCustomWebBrowser.RemoveNotification(Notify: IWebBrowserEvents);
var
  I: Integer;
begin
  if Notify is IWebBrowserControl then
    Exit;
  I := FEvents.IndexOf(Notify);
  if I > -1 then
    FEvents.Delete(I);
end;

{ TCustomWebBrowser.IWebBrowserEvents }

procedure TCustomWebBrowser.DoError(const Uri: string; ErrorCode: LongWord; const ErrorMessage: string; var Handled: Boolean);
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoError(Uri, ErrorCode, ErrorMessage, Handled);
  if Assigned(FOnError) then
    FOnError(Self, Uri, ErrorCode, ErrorMessage, Handled);
end;

procedure TCustomWebBrowser.DoReady;
var
  E: IWebBrowserEvents;
  S: string;
begin
  FReady := True;
  if FHtmlDefined then
    LoadHtml(FHtml)
  else
  begin
    S := FUri;
    FUri := '';
    Location := S;
  end;
  DesignMode := DesignMode;
  SourceView := SourceView;
  ZoomContent := ZoomContent;
  ZoomFactor := ZoomFactor;
  for E in FEvents do
    E.DoReady;
end;

procedure TCustomWebBrowser.DoContextMenu(X, Y: Integer; HitTest: TWebHitTest;
  const Link, Media: string; var Handled: Boolean);
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoContextMenu(X, Y, HitTest, Link, Media, Handled);
  if Assigned(FOnContextMenu) then
    FOnContextMenu(Self, X, Y, HitTest, Link, Media, Handled);
end;

procedure TCustomWebBrowser.DoHitTest(X, Y: Integer; HitTest: TWebHitTest;
  const Link, Media: string);
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoHitTest(X, Y, HitTest, Link, Media);
  if Assigned(FOnHitTest) then
    FOnHitTest(Self, X, Y, HitTest, Link, Media);
end;

procedure TCustomWebBrowser.DoLoadStatusChange;
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoLoadStatusChange;
  if Assigned(FOnLoadStatusChange) then
    FOnLoadStatusChange(Self);
end;

procedure TCustomWebBrowser.DoLocationChange;
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoLocationChange;
  if Assigned(FOnLocationChange) then
    FOnLocationChange(Self);
end;

procedure TCustomWebBrowser.DoNavigate(const Uri: string; var Action: TWebNavigateAction);
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoNavigate(Uri, Action);
  if Assigned(FOnNavigate) then
    FOnNavigate(Self, Uri, Action);
end;

procedure TCustomWebBrowser.DoProgress(Progress: Integer);
var
  L: TWebLoadStatus;
  E: IWebBrowserEvents;
  F: TCustomForm;
  S: string;
begin
  L := LoadStatus;
  if L <> FLoadStatus then
  begin
    FLoadStatus := L;
    DoLoadStatusChange;
  end;
  if L in [lsCommited, lsComplete, lsLayout] then
  begin
    S := FWidget.Location;
    if (S <> '') and (S <> FUri) then
    begin
      FUri := S;
      if csDesigning in ComponentState then
      begin
        F := GetParentForm(Self);
        if (F <> nil) and (F.Designer <> nil) then
          F.Designer.Modified;
      end;
      DoLocationChange;
    end;
  end;
  for E in FEvents do
    E.DoProgress(Progress);
  if Assigned(FOnProgress) then
    FOnProgress(Self, Progress);
end;

procedure TCustomWebBrowser.DoFavicon(Icon: TGraphic);
var
  E: IWebBrowserEvents;
begin
  FFavicon.Free;
  FFavicon := TGraphicClass(Icon.ClassType).Create;
  FFavicon.Assign(Icon);
  for E in FEvents do
    E.DoFavicon(FFavicon);
  if Assigned(FOnFavicon) then
    FOnFavicon(Self);
end;

procedure TCustomWebBrowser.DoConsoleMessage(const Message, Source: string; Line: Integer);
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoConsoleMessage(Message, Source, Line);
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(Self, Message, Source, Line);
end;

procedure TCustomWebBrowser.DoScriptDialog(Dialog: TWebScriptDialog;
  const Message: string; var Input: string; var Accepted: Boolean;
  var Handled: Boolean);
var
  E: IWebBrowserEvents;
begin
  Handled := False;
  for E in FEvents do
  begin
    Accepted := False;
    E.DoScriptDialog(Dialog, Message, Input, Accepted, Handled);
    if Handled then Exit;
  end;
  Accepted := False;
  if Assigned(FOnScriptDialog) then
    FOnScriptDialog(Self, Dialog, Message, Input, Accepted, Handled);
  if not Handled then
  begin
    Accepted := True;
    case Dialog of
      sdAlert: MessageDlg('Alert', Message, mtInformation, [mbOK], 0);
      sdConfirm: Accepted := MessageDlg('Confirmation', Message, mtInformation,
        [mbYes, mbNo], 0) = mrYes;
      sdPrompt: Accepted := InputQuery('Prompt', Message, False, Input);
    end;
  end;
end;

procedure TCustomWebBrowser.DoRequest(var Uri: string);
var
  E: IWebBrowserEvents;
begin
  for E in FEvents do
    E.DoRequest(Uri);
  if Assigned(FOnRequest) then
    FOnRequest(Self, Uri);
end;

{ TCustomWebBrowser normal methods }

procedure TCustomWebBrowser.Load(const Uri: string);
var
  F: TCustomForm;
  S, L: string;
begin
  if not (csLoading in ComponentState) then
  begin
    FHtmlDefined := False;
    if csDesigning in ComponentState then
    begin
      F := GetParentForm(Self);
      if (F <> nil) and (F.Designer <> nil) then
        F.Designer.Modified;
    end;
  end;
  S := Trim(Uri);
  if S = '' then
  begin
    FUri := S;
    Exit;
  end;
  L := LowerCase(S);
  if (Pos('http://', L) <> 1) and (Pos('https://', L) <> 1) and
    (Pos('file://', L) <> 1) and (Pos('about:', L) <> 1) then
    S := 'http://' + S;
  if not FReady then
  begin
    FUri := S;
    DoLocationChange;
    Exit;
  end;
  FUri := S;
  if csDesigning in ComponentState then
  begin
    F := GetParentForm(Self);
    if (F <> nil) and (F.Designer <> nil) then
      F.Designer.Modified;
  end;
  FWidget.Load(FUri);
  DoLocationChange;
end;

procedure TCustomWebBrowser.LoadHtml(const Html: string);
var
  F: TCustomForm;
  S: string;
begin
  S := Trim(Html);
  if S <> '' then
  begin
    FWidget.LoadHtml(Html);
    FHtml := Html;
    FHtmlDefined := True;
    if csDesigning in ComponentState then
    begin
      F := GetParentForm(Self);
      if (F <> nil) and (F.Designer <> nil) then
        F.Designer.Modified;
    end;
  end;
end;

procedure TCustomWebBrowser.Stop;
begin
  FWidget.Stop;
end;

procedure TCustomWebBrowser.Reload;
begin
  if FHtmlDefined then
    LoadHtml(FHtml)
  else
    FWidget.Reload;
end;

procedure TCustomWebBrowser.ExecuteScript(Script: string);
begin
  FWidget.ExecuteScript(Script);
end;

function TCustomWebBrowser.Snapshot: TGraphic;
begin
  Result := FWidget.Snapshot;
end;

procedure TCustomWebBrowser.BackOrForward(Steps: Integer);
begin
  FWidget.BackOrForward(Steps);
end;

function TCustomWebBrowser.BackOrForwardExists(Steps: Integer): Boolean;
begin
  Result := FWidget.BackOrForwardExists(Steps);
end;

procedure TCustomWebBrowser.SetLocation(const Value: string);
begin
  Load(Value);
end;

procedure TCustomWebBrowser.PropHtmlRead(Reader: TReader);
begin
  FHtml := Reader.ReadString;
end;

procedure TCustomWebBrowser.PropHtmlWrite(Writer: TWriter);
begin
  Writer.WriteString(FHtml);
end;

procedure TCustomWebBrowser.PropHtmlDefinedRead(Reader: TReader);
begin
  FHtmlDefined := Reader.ReadBoolean;
end;

procedure TCustomWebBrowser.PropHtmlDefinedWrite(Writer: TWriter);
begin
  Writer.WriteBoolean(FHtmlDefined);
end;

procedure TCustomWebBrowser.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty('Html', PropHtmlRead, PropHtmlWrite, True);
  Filer.DefineProperty('HtmlDefined', PropHtmlDefinedRead, PropHtmlDefinedWrite, True);
end;

function TCustomWebBrowser.GetDesignMode: Boolean;
begin
  Result := FWidget.DesignMode;
end;

procedure TCustomWebBrowser.SetDesignMode(Value: Boolean);
begin
  FWidget.DesignMode := Value;
end;

function TCustomWebBrowser.GetSourceView: Boolean;
begin
  Result := FWidget.SourceView;
end;

procedure TCustomWebBrowser.SetSourceView(Value: Boolean);
begin
  FWidget.SourceView := Value;
end;

function TCustomWebBrowser.GetLoadStatus: TWebLoadStatus;
begin
  Result := FWidget.LoadStatus;
end;

function TCustomWebBrowser.GetTitle: string;
begin
  Result := FWidget.Title;
end;

function TCustomWebBrowser.GetZoomContent: Boolean;
begin
  Result := FWidget.ZoomContent;
end;

procedure TCustomWebBrowser.SetZoomContent(Value: Boolean);
begin
  FWidget.ZoomContent := Value;
end;

function TCustomWebBrowser.GetZoomFactor: Single;
begin
  Result := FWidget.ZoomFactor;
end;

procedure TCustomWebBrowser.SetZoomFactor(Value: Single);
begin
  FWidget.ZoomFactor := Value;
end;

procedure WebControlsRegister;
begin
  if WebControlsAvaiable then
  begin
    RegisterWSComponent(TWebInspector, WebInspectorWSClass);
    RegisterWSComponent(TWebBrowser, WebBrowserWSClass);
  end;
end;

initialization
  WebControlsRegister;
end.

