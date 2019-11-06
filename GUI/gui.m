function cli = gui(varargin)
global session 

guipath = which(mfilename);
path = [cutpath(cutpath(guipath)) '/'];


systempath = [path 'Systems/'];
setupPath(path);

DEBUG = ~ismember('nodebug' , varargin);
%if (DEBUG)
%   Console();
%    printc(mfilename , ['Path =  ' path]);
%end

session = Session(systempath);
session.DEBUG = DEBUG;




mwindowhandle = session.getWindowManager().createMainWindow();


handlelist = [];

handle = uimenu(mwindowhandle , 'Label' , 'System');
handlelist(end+1) = handle;
uimenu(handle , 'Label' , 'Systembrowser' , 'Callback', @(o,e) MainPanel.browsesystem(session,systempath)  );
MenuItem(handle, @() CommanderModel.manageCurrentDiagram(session), 'Organize Diagrams' , session , @() ~isempty(session.system) , 'stateChanged');

uimenu(handle, 'Label' , 'Exit' , 'Callback' , @(o,e)  closemainwindow(session));

handle = uimenu(mwindowhandle , 'Label' , 'Type');
handlelist(end+1) = handle;

SelectPointsMenu(handle , StaticPointType() , session);
SelectBranchMenu(handle,'uimenu' ,  session , session.getBranchManager());



handle = uimenu(mwindowhandle , 'Label' , 'Setting');
handlelist(end+1) = handle;



WindowLaunchButton(handle , session.getWindowManager() , 'uimenu', ...
       @(fhandle) ContinuerPanel(fhandle,session.continuedata), 'continuer');


WindowLaunchButton(handle , session.getWindowManager() , 'uimenu', ...
       @(fhandle) StarterPanel(fhandle,session.starterdata), 'starter');   
   

handle = uimenu(mwindowhandle , 'Label' , 'Output');
handlelist(end+1) = handle;

gm = uimenu(handle , 'Label' , 'Graphic');
SyncHandles(session, gm , @() session.numericAllowed());
uimenu(gm, 'Label' , '2D plot' , 'Callback' , @(o,e) session.getPlotManager().create2Dplot(session));
uimenu(gm, 'Label' , '3D plot' , 'Callback' , @(o,e) session.getPlotManager().create3Dplot(session));
uimenu(gm, 'Label' , 'Multiplier plot' , 'Callback' , @(o,e) session.getPlotManager().createMultPlot(session));

SelectPlotMenu( gm , session , 'Separator' , 'on');
   
WindowLaunchButton(handle , session.getWindowManager() , 'uimenu', ...
       @(fhandle) session.launchNumeric(fhandle) , 'numeric');   

   


handle = uimenu(mwindowhandle , 'Label' , 'Compute');
handlelist(end+1) = handle;

MenuItem(handle, @() ContinuerManager.computeForward(session) , @() 'Forward' , session , @() session.performContinueAllowed() , 'stateChanged');
MenuItem(handle, @() ContinuerManager.computeBackward(session), @() 'Backward' , session , @() session.performContinueAllowed() , 'stateChanged');
MenuItem(handle ,@() ContinuerManager.computeExtend(session) , @() 'Extend' , session, @() session.performExtendAllowed(), 'stateChanged');

handle = uimenu(mwindowhandle , 'Label' , 'Options');
ConfigMenu(handle, session.configmanager);

WindowLaunchButton(handle , session.getWindowManager() , 'uimenu', ...
       @(fhandle) ColorConfigPanel(fhandle , session) , 'coloropt');   

handlelist(end+1) = handle;


if(DEBUG)
    handle = uimenu(mwindowhandle , 'Label' , 'Debug');
    %SelectPlotMenu( handle , session );
    uimenu(handle , 'Label' , 'Display OptionsStruct' , 'Callback', @(o,e) doDisplay(session.optioninterface)  );
    uimenu(handle , 'Label' , 'Console' , 'Callback' , @(o,e) Console(session) );
    SelectSwitchMenu( handle , session.sessiondata , 'Switches' ,'debug');
    uimenu(handle , 'Label' , 'session unlock' , 'Callback' , @(o,e) session.unlock());
    
    
    %handlelist(end+1) = handle;
end

MainPanel( mwindowhandle , session );

set(mwindowhandle , 'Visible' , 'on' );

SyncHandles(session, handlelist, @() session.isUnlocked());

if (nargout == 1)
   cli = CommandLineInterface(session);  
end

if (DEBUG)
%    Console(session);
	Console.monitorEvents(session , 'recursive');
% 	Console.monitorEvents(session.continuedata);
% 	Console.monitorEvents(session.starterdata);
% 	Console.monitorEvents(session.windowmanager);
% 	Console.monitorEvents(session.branchmanager);
% 	Console.monitorEvents(session.plotmanager);
end



end



function closemainwindow(session)
	session.getWindowManager().closeAllWindows();
end




