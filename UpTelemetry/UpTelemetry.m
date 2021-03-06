function varargout = UpTelemetry(varargin)
% UPTELEMETRY MATLAB code for UpTelemetry.fig
%      UPTELEMETRY, by itself, creates a new UPTELEMETRY or raises the existing
%      singleton*.
%
%      H = UPTELEMETRY returns the handle to a new UPTELEMETRY or the handle to
%      the existing singleton*.
%
%      UPTELEMETRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UPTELEMETRY.M with the given input arguments.
%
%      UPTELEMETRY('Property','Value',...) creates a new UPTELEMETRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UpTelemetry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UpTelemetry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UpTelemetry

% Last Modified by GUIDE v2.5 01-Mar-2017 17:23:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UpTelemetry_OpeningFcn, ...
                   'gui_OutputFcn',  @UpTelemetry_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%% Form direct functions

% --- Executes just before UpTelemetry is made visible.
function UpTelemetry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UpTelemetry (see VARARGIN)

% Start by closing serial port and all files 
delete(instrfindall);
fclose all;

%% Include global variables

% From config
global port
global baudSelect
global bitstream
global sLogName

global startChar
global delimiter
global CSDelimiter
global endChar
global lengthParam

global sVerbose

% Other Globals
global serialOpen
global serialRec
global GPSGet
global GPSRec
global maxLines
global warnAudio

serialOpen = false;
serialRec = false;
sVerbose = false;
GPSGet = false;
GPSRec = false;
maxLines = 64;
warnAudio = audioplayer([sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)], 22050);

% Get data from user file
try
   % Open file
   configID = fopen('data\userConfig.txt');
    
   % Read file into cell array
   c = textscan(configID,'%s %*s %s');
   [lines,a] = size(c{1});
   
    for i = 1:lines
        config(i,1) = c{1}(i,1);
        config(i,2) = c{2}(i,1);
    end
   
   % Get configurations from cell array 
   port = configScan(config,'port');
   port = port{1};
   baudSelect = configScan(config,'baudSelect');
   baudSelect = baudSelect{1};
   bitstream = configScan(config,'bitstream');
   bitstream =  bitstream{1};
   sLogName = configScan(config,'sLog');
   sLogName = sLogName{1};
   startChar = configScan(config,'startChar');
   startChar = startChar{1};
   delimiter = configScan(config,'delimiter');
   delimiter = delimiter{1};
   CSDelimiter = configScan(config,'CSDelimiter');
   CSDelimiter = CSDelimiter{1};
   endChar = configScan(config,'endChar');
   endChar = endChar{1};
   lengthParam = configScan(config,'lengthParam');
   lengthParam = lengthParam{1};
   
   % Set up in form
   set(handles.tbx_serialport,'String',port);
   set(handles.tbx_bitstream,'String',bitstream);
   set(handles.tbx_seriallogname,'String',sLogName);
   set(handles.ppm_baud,'Value',str2double(baudSelect));
   lengthParam = str2num(lengthParam);
   
catch
    
    % Warning Sound
    play(warnAudio);
    msgbox('Error retrieving some user data. Settings are default','Error'); 
    
end

    fclose(configID);

% Choose default command line output for UpTelemetry
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Executes on close attempt
function frm_serialgpsmonitor_CloseRequestFcn(hObject, eventdata, handles)
global warnAudio

%Set default
exitConfirm = false;
% Get dialog result
exitConfirm = dialogWarnYN('Are you sure you wish to close?','Close',warnAudio);

if exitConfirm == true
    delete(hObject);
end

% --- Executes on delete
function frm_serialgpsmonitor_DeleteFcn(hObject, eventdata, handles)

% Globals
global port
global baudSelect
global bitstream
global sLogName
global startChar
global delimiter
global CSDelimiter
global endChar
global lengthParam

try
    % Get user data
    port =          get(handles.tbx_serialport,'String');
    baudSelect =    get(handles.ppm_baud,'Value');
    bitstream =     get(handles.tbx_bitstream,'String');
    sLogName =      get(handles.tbx_seriallogname,'String');
    
    % Save user data
    configID = fopen('data\userConfig.txt','w');

    fprintf(configID,['port'        ' = '   port                '\n']); 
    try
        fprintf(configID,['baudSelect'  ' = '   num2str(baudSelect) '\n']);
    catch
        fprintf(configID,['baudSelect'  ' = '   '5'                 '\n']);
    end     
    fprintf(configID,['bitstream'	' = '   bitstream           '\n']); 
    fprintf(configID,['sLog'        ' = '   sLogName            '\n']);
    fprintf(configID,['startChar'	' = '   startChar           '\n']); 
    fprintf(configID,['delimiter'	' = '   delimiter           '\n']); 
    fprintf(configID,['CSDelimiter'	' = '	CSDelimiter         '\n']); 
    fprintf(configID,['endChar'     ' = ' 	endChar             '\n']); 
    fprintf(configID,['lengthParam' ' = ' 	num2str(lengthParam)    ]); 
    
    fclose(configID);

catch
end

%Stop logging serial/GPS



%Close Serial Port
global serialOpen
serialOpen = false;

delete(instrfindall);
fclose all;
close all;

% Update
guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = UpTelemetry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Text boxes, other inputs

% --- Text Change(Serial Port)
function tbx_serialport_Callback(hObject, eventdata, handles)
%Global Variables

global port
port = get(hObject,'String');

%Update
guidata(hObject, handles);

% --- Selection Change(Baud)
function ppm_baud_Callback(hObject, eventdata, handles)
% Global Variables
global baudRate

string = get(hObject,'String');
val = get(hObject,'Value');
baudRate = string{val};

%Update
guidata(hObject, handles);

% --- Text Change(Bitstream Length)
function tbx_bitstream_Callback(hObject, eventdata, handles)

global bitstream 

try
    bitstream = str2num(get(hObject,'String'));
catch
    % Warning Dialog
    play(warnAudio);
    msgbox('Enter only an integer','Error','modal');
    
    set(hObject,'String','');
end
    
% Update
guidata(hObject,handles);

% --- Text Change(Serial Log)
function tbx_seriallogname_Callback(hObject, eventdata, handles)

% Globals
global sLogName

sLogName = get(hObject, 'String'); 

% Update
guidata(hObject,handles);

%% SERIAL BUTTONS

% --- Toggles the reading and displaying of serial data
function btn_toggleserial_Callback(hObject, eventdata, handles)

% Declare variables
global port
global baudRate
global bitstream

global serialOpen
global serialRec
global serialConnect
global consoleString

global GPSGet
global consoleGPS

global sVerbose

global maxLines

global sLogFID

global startChar
global delimiter
global CSDelimiter
global endChar

global warnAudio

degSym = char(176);

%% If port is closed, check settings
if  serialOpen == false

    %% Open Port
    
    % Get values
    port = get(handles.tbx_serialport,'String');
                bString = get(handles.ppm_baud,'String');
    baudRate = bString{get(handles.ppm_baud,'Value')};
    bitstream = get(handles.tbx_bitstream,'String');
    
    try % Attempt serial connection
        
        bitstream = str2double(bitstream);
        if isnumeric(bitstream) == false
            
            % Warning Dialog
            play(warnAudio);
            errordlg('Port settings invalid.','Error','modal');
            return
            
        elseif isnan(bitstream) 
            
            % Warning Dialog
            play(warnAudio);
            errordlg('Port settings invalid.','Error','modal');
            return      
            
        end    
         
        delete(instrfindall);
        fclose all;
        
        serialConnect = serial(port);

        baud = str2double(baudRate);
        set(serialConnect,'BaudRate',baud);
        set(serialConnect,'DataBits',8);
        set(serialConnect,'StopBits',1);
        set(serialConnect,'Parity','none');
        
        fopen(serialConnect);
        
        
    catch % Settings invalid
        
        % Warning Dialog
        play(warnAudio);
        errordlg('Port name or settings invalid.','Error','modal');
        return
        
    end
    
        %% Print Header
        
        [consoleString] = consoleUpdate('>> Serial Link Created.',handles.tbx_serialmonitor,maxLines);
        
        if get(handles.rbn_parse,'Value') % parsing
            serialInfo =   ['>> Port: ', port,...
                            ' / Baud: ', baudRate];
                        
        else % set length
            serialInfo =   ['>> Port: ', port,...
                            ' / Baud: ', baudRate,...
                            ' / Bitstream: ', num2str(bitstream)];
        end
            
        consoleUpdate(serialInfo,handles.tbx_serialmonitor,maxLines);          
        
        serialOpen = true; % Track whether port is open, as ML has trouble doing it :/
    
        %% Alter form properties
        formAlter(handles,'serialOn');
        guidata(hObject,handles);
        %Update
        
        
        stringBuffer = '';    
        dataLength = 0;
        stringReady = false;
        dataEnded = false; 
        f = 0;
        %% Continuallly update monitor
              
        while (1)
            
            % Get new input from serial port
            try
                
                if get(handles.rbn_parse,'Value')
                    % bitstream length is 1, as characters are being taken in one at a time
                    getSerial = '';
                    
                    while(1)
                        
                        getSerial = fscanf(serialConnect,'%s',1);
                        
                        consoleUpdate('',handles.tbx_serialmonitor,maxLines);
                        if isempty(getSerial) == false
                            consoleUpdate('',handles.tbx_serialmonitor,maxLines);
                            f = 0;
                            break 
                        end
                        
                        f = f + 1;
                        consoleUpdate('',handles.tbx_serialmonitor,maxLines);
                        
                        if f == 5
                            consoleUpdate('>> Serial error: NO UPLINK.',handles.tbx_serialmonitor,maxLines);
                            f = 0;
                        end
                            
                    end
                   
                    
                    %% If value is recieved, interpret
                    switch getSerial
                    
                        case startChar % Start new string buffer
                            stringBuffer = '';
                            dataLength = 1;
                            dataEnded = false;
                            stringBuffer = strcat(stringBuffer, getSerial);
                        
                        case CSDelimiter % Divide data substring from checksum & length
                            
                            dataEnded = true;
                            dataLength = (dataLength + 1);
                            stringBuffer = strcat(stringBuffer, getSerial);
                            
                            % Prepare to be checked
                            checkLength = string(dataLength);
                            
                        case delimiter
                                
                            stringBuffer = strcat(stringBuffer, getSerial);
                            dataLength = (dataLength + 1);
                            if dataEnded == true
                                
                                cSum = checkSum(stringBuffer,dataLength,'xor');
                                
                            end
                                
                        case endChar % The last character of the string
                            
                            [lengthPass,checkSumPass,syntaxPass] = checkInput(stringBuffer,checkLength,delimiter,CSDelimiter,cSum);
                            
                            if syntaxPass
                               
                                if lengthPass && checkSumPass
                                   
                                    % Complete and pass on string
                                    stringBuffer = strcat(stringBuffer, getSerial);
                                    stringReady = true;
                                    
                                elseif lengthPass == false
                                    
                                    % Must mean length failed
                                    consoleUpdate('>> LENGTH FAILED!',handles.tbx_serialmonitor,maxLines);
                                   
                                else
                                
                                    % Must mean checksum only failed
                                    consoleUpdate('>> CHECKSUM FAILED!',handles.tbx_serialmonitor,maxLines);
                                    
                                end
                                
                            else
                                    
                                % Other error with syntax (or with code)
                                consoleUpdate('>> SYNTAX FAILED!',handles.tbx_serialmonitor,maxLines);
                                
                            end
                        
                        otherwise % For all other characters
                        
                         dataLength = (dataLength + 1); % Keep track of data length
                         stringBuffer = strcat(stringBuffer, getSerial); % Add on to the incomplete datastring
                         
                    end % End switch
                 
                else
                    
                    % This is if the bitstream is constant
                    getSerial = fscanf(serialConnect,'%s',bitstream);
                    stringBuffer = getSerial;
                    stringReady = true;
                    
                end
            
            catch
                %% If failed must mean serial port is closed or have trouble opening
                
                if serialOpen == false
                   return 
                end
                
                serialOpen = false;
                fclose all;
                delete(instrfindall);
                
                %% Alter form properties
                formAlter(handles,'serialOff');
                guidata(hObject,handles);
                
                % Print to serial monitor
                consoleUpdate('>> Serial error: connection not valid or error parsing.',handles.tbx_serialmonitor,maxLines);
                return 
                
            end
            
            if stringReady == true
                
                guidata(hObject, handles);
                if sVerbose
                    
                    %Print to monitor           
                    [consoleString] = consoleUpdate(stringBuffer,handles.tbx_serialmonitor,maxLines);
                
                else
                    %Print to monitor           
                    [consoleString] = consoleUpdate('',handles.tbx_serialmonitor,maxLines);
                end
                
                stringReady = false;
                
                %% Record raw serial data
                if serialRec == true
                %try
                   % Write to file
                   fprintf(sLogFID,stringBuffer);
                   fprintf(sLogFID,'\n');
               %catch
                end
            
                %% Parse, display, record GPS
                if GPSGet == true
                    
                % Parse
                   
                    try
                
                        GPSData = textscan(stringBuffer,'%s','Delimiter',',');
                        GPSData = GPSData{1,1};
                    
                        if (GPSData{6,1} == '1') % check GPSVALID field
                    
                            saveGPS = strcat([GPSData{4,1}, ',', GPSData{5,1}, ',', GPSData{7,1}]);
                    
                            if get(handles.cbx_GPSVerbose,'Value') % If verbose is enabled
                        
                                if get(handles.cbx_showFt,'Value')
                            
                                    altFt = char(string(3.28084* str2double(GPSData{7,1})));
                                    GPSString = strcat([GPSData{4,1}, degSym, ', ', GPSData{5,1}, degSym,', ', GPSData{7,1}, ' m (', altFt, 'ft)']);
                            
                                elseif get(handles.cbx_units,'Value')
                            
                                    GPSString = strcat([GPSData{4,1}, degSym, ', ', GPSData{5,1}, degSym, ', ', GPSData{7,1}, ' m']);
                            
                                else
                            
                                    GPSString = saveGPS;
                            
                                end
                    
                                % Update Monitor
                                [consoleGPS] = consoleUpdate(GPSString,handles.tbx_GPSmonitor,maxLines);
                            end
                        else
                            %GPS is not valid
                            [consoleGPS] = consoleUpdate('>> GPS INVALID!',handles.tbx_GPSmonitor,maxLines);
                            
                        end
                    
                    catch
                        %Error Parsing GPS
                        [consoleGPS] = consoleUpdate('>> GPS PARSING ERROR!',handles.tbx_GPSmonitor,maxLines);
                        
                    end
                    
                end
            
            else
                
            end

        end
    
else 
    %% Close port
    serialOpen = false;
    
    fclose all;
    delete(instrfindall);
     
    % Alter the form
    formAlter(handles,'serialOff');
    guidata(hObject,handles);
    
    % Print to serial monitor
    consoleUpdate('>> Serial Link Closed',handles.tbx_serialmonitor,'String');
    
end    

% Update
guidata(hObject,handles);

% --- Reset Serial Connection
function btn_rstserial_Callback(hObject, eventdata, handles)


% Update
guidata(hObject,handles);

% --- Toggles the recording of serial strings to a text file
function btn_recordserial_Callback(hObject, eventdata, handles)

% Global Variables
global serialRec
global sLogFID
global warnAudio

global maxLines

try
       
    sName = string(get(handles.tbx_seriallogname,'String'));
    sLog = strcat('logs\',sName,'.txt');

catch % error
    
    % Warning Dialog
    play(warnAudio);
    errordlg('Error finding file.','Error','modal');
    
end

if serialRec == false
    
    %% Check Filename
    sLog = char(sLog);
    if exist(sLog, 'file') == 2
        if dialogWarnYN('A file with this name already exists, Do you wish to overwrite it?','Warning',warnAudio)
            delete(sLog);
        else
            return
        end
    end
    
    %% Create File, Start recording
    sLogFID = fopen(sLog,'w');
      
   % Alter the form
    formAlter(handles,'serialRecOn');
    guidata(hObject,handles);
    
    % Notify through console
    consoleUpdate('>> Serial Recording Started.',handles.tbx_serialmonitor,maxLines);

    % Track recording status
    serialRec = true;
    guidata(hObject,handles);
    
else 
    %% Stop Recording
    serialRec = false;
    fclose(sLogFID);
    
   % Alter the form
    formAlter(handles,'serialRecOff');
    guidata(hObject,handles);
    
    % Print to serial monitor
    consoleUpdate('>> Serial Recording Stopped',handles.tbx_serialmonitor,maxLines);
   
end

% --- Clears all text from the serial monitor
function btn_clearmonitor_Callback(hObject, eventdata, handles)

set(handles.tbx_serialmonitor,'String','');

% --- Prints string into the serial monitor or sends it over serial
function btn_serialsend_Callback(hObject, eventdata, handles)

global consoleString
global maxLines
global serialConnect

serialInput = get(handles.tbx_serialinput,'String');

if get(handles.cbx_serialWrite)
    lineID = string('=> ');
    
    % Send data over serial
    fprintf(serialConnect,serialInput);
    
else
    % This is if the string is not being sent to the serial object 
    lineID = string('-> ');
end

serialInput = lineID + serialInput; 
set(handles.tbx_serialinput,'String','') 

% Print to monitor
[consoleString] = consoleUpdate(serialInput,handles.tbx_serialmonitor,maxLines);

%% GPS BUTTONS

% --- Executes on button press in btn_toggleGPS.
function btn_toggleGPS_Callback(hObject, eventdata, handles)

global GPSGet

if GPSGet == false
    GPSGet = true;
    
    % Alter the form
    formAlter(handles,'gpsOn');
    guidata(hObject,handles);
    
    % Print to monitor
    consoleUpdate('>> Getting GPS', handles.tbx_GPSmonitor,'String');
    
else
    GPSGet = false;
    
    % Alter the form
    formAlter(handles,'gpsOff');
    guidata(hObject,handles);
    
    % Print to monitor
    consoleUpdate('>> GPS Stopped', handles.tbx_GPSmonitor,'String');
    
end

% --- Clears the GPS monitor
function btn_clearGPS_Callback(hObject, eventdata, handles)

consoleUpdate('',handles.tbx_GPSmonitor,0);

% --- Opens the kml converter form
function btn_kmlConvert_Callback(hObject, eventdata, handles)

global warnAudio

try
    kmlConverter;
catch
    play(warnAudio);
    errordlg('Could not find the kmlConverter program.','Error','modal');
end

%% PARSE SETTINGS

% --- Executes on button press in btn_parseSettings.
function btn_parseSettings_Callback(hObject, eventdata, handles)
% hObject    handle to btn_parseSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global startChar
global delimiter
global CSDelimiter
global endChar
global lengthParam
global warnAudio

% try
    [startChar, delimiter, CSDelimiter, endChar] = parseSettings(startChar, delimiter, CSDelimiter, endChar,warnAudio);
%     if lengthParam
%         set(handles.txt_length,'enable', 'on');
%         set(handles.tbx_bitstream,'enable', 'on');
%     else
%         set(handles.txt_length,'enable', 'off');
%         set(handles.tbx_bitstream,'enable', 'off');
%     end
% catch
% end

% --- Executes on button press in rbn_parse.
function rbn_parse_Callback(hObject, eventdata, handles)

% global lengthParam
% 
% if lengthParam
%     set(handles.txt_length,'enable', 'on');
%     set(handles.tbx_bitstream,'enable', 'on');
% else
    set(handles.txt_length,'enable', 'off');
    set(handles.tbx_bitstream,'enable', 'off');
% end

set(handles.btn_parseSettings,'enable', 'on');

% --- Executes on button press in rbn_setLength.
function rbn_setLength_Callback(hObject, eventdata, handles)

set(handles.btn_parseSettings,'enable', 'off');

set(handles.txt_length,'enable', 'on');
set(handles.tbx_bitstream,'enable', 'on');

%% GPS CHECKBOXES

% --- Executes on button press in cbx_GPSVerbose.
function cbx_GPSVerbose_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    
    set(handles.cbx_units,'enable','on');
    
else
    
    set(handles.cbx_units,'enable','off');
    
end

% --- Executes on button press in cbx_units.
function cbx_units_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    
    set(handles.cbx_showFt,'enable','on');
    
else
    
    set(handles.cbx_showFt,'enable','off');
    
end

%% OTHERS

% haven't made this yet
function mnu_1_Callback(hObject, eventdata, handles)

% --- Executes on key press with focus on tbx_serialinput and none of its controls.
function tbx_serialinput_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to tbx_serialinput (see GCBO)
if eventdata.Character == enter
   
    %do the send data thing
    btn_serialsend_Callback(handles.btn_serialsend_Callback, eventdata, handles);
    
end
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbx_sVerbose.
function cbx_sVerbose_Callback(hObject, eventdata, handles)

global sVerbose

sVerbose = get(hObject,'Value');
