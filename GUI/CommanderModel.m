classdef CommanderModel < handle
    %COMMANDERMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diagramlist;
        
        
        session
        sessioncurrentdiagramname
        %
        diagramselection
        
        curveselection
        
        system
        
        curvemanager = {[] , []};
        diagrampreview = {[],[]};
        curvepreview = [];
    end
    
    events
        diagramSelectionChanged
        diagramListChanged
        curveSelection
    end
    
    methods
        function obj = CommanderModel(session , system)
            obj.session = session;
            obj.sessioncurrentdiagramname = session.getCurveManager().getDiagramName();
            obj.system = system;
            obj.diagramlist = system.getDiagramList();

            
            if (length(obj.diagramlist) > 1)
                obj.diagramselection = [1 2];
            else
                obj.diagramselection = [1 1];
            end
            
            
            obj.curveselection = [1 1];
 
        end
        

        function reconfigure(obj)
           obj.diagramlist = obj.system.getDiagramList(); 
           obj.notify('diagramListChanged');
        end
        
        
        
        function selectDiagram(obj, index , diagramindex)
            obj.diagramselection(index) = diagramindex;
            obj.curvemanager{index} = [];
            obj.notify('diagramSelectionChanged' , CommanderModelEvent(index, obj.getCurveList(index)  , 1 ));
        end
        
        function selectCurve(obj, index , curveindex)
            obj.curveselection(index) = curveindex;
            
            %disp(['curve ' num2str(curveindex) ' selected on ' num2str(index) ]);
            obj.notify('curveSelection' , CommanderModelEvent(index, [] , curveindex ));
        end
        
        function curvename = getSelectedCurve(obj, index)
            curvename = obj.curveselection(index);
        end
        
        function curvedescr = getCurve(obj , index)
            i = obj.curveselection(index);
            cm = obj.getCurveManager(index);
            curvedescr = cm.getCurveByIndex(i);
        end
        
        function bool = isValidCurve(obj, index)
            i = obj.curveselection(index);
            bool =    (i > 0) && ( i <= length( obj.getCurveList(index) ));
        end
        
        
        
        function list = getCurveList(obj, index)
            list =  CurveManager.getCurveNamesList([obj.system.getPath() '/' obj.diagramlist{obj.diagramselection(index)} ]);
        end
        
        
        function dindex = getSelectedDiagram(obj , index)
            dindex = obj.diagramselection(index);
        end
        
        function list = getDiagramList(obj)
            list = obj.diagramlist;
        end
        
        function cm = getCurveManager(obj , index)
            if (isempty(obj.curvemanager{index}))
                scm = obj.session.getCurveManager();
                if strcmp(scm.getDiagramName() , obj.diagramlist{obj.diagramselection(index)})
                    obj.curvemanager{index} = scm;
                else
                    obj.curvemanager{index} = CurveManager(obj.session,[obj.system.getPath() '/' obj.diagramlist{obj.diagramselection(index)}]);
                end
            end
            cm =  obj.curvemanager{index};
        end
        
        
        function moveCurve(obj, fromIndex, toIndex)
            fromCM = getCurveManager(obj , fromIndex);
            toCM   = getCurveManager(obj, toIndex);
            fromList = getCurveList(obj, fromIndex);
            cname = fromList{obj.curveselection(fromIndex)};
            
            [status , message] = CurveManager.moveCurve(obj.session , cname , fromCM , toCM);
           
            if (~status)
               errordlg(message, 'move curve'); 
            end
            
            obj.notify('diagramSelectionChanged' , CommanderModelEvent(1, obj.getCurveList(1)  , CommanderModelEvent.ADJUSTINDEX  ));
            obj.notify('diagramSelectionChanged' , CommanderModelEvent(2, obj.getCurveList(2)  , CommanderModelEvent.ADJUSTINDEX  ));
        end
        
        function moveFromLeft(obj)
           obj.moveCurve(1 , 2); 
            
        end
        function moveFromRight(obj)
           obj.moveCurve(2 , 1); 
        end
        
        function b = moveFromLeftValid(obj)
            b = (obj.diagramselection(1) ~= obj.diagramselection(2)) && ~isempty(obj.getCurveList(1)); 
        end
        
        function b = moveFromRightValid(obj)
            b = (obj.diagramselection(1) ~= obj.diagramselection(2)) && ~isempty(obj.getCurveList(2));             
        end
        function b = isValid(obj, index)
            b =  ~isempty(obj.getCurveList(index));
        end
        
        
        function deleteCurve(obj, index)
            cmanager = getCurveManager(obj , index);
            list = getCurveList(obj, index);
            cname = list{obj.curveselection(index)};
            %disp(['deleting: ' cname]);
            if strcmp( questdlg(['Are you sure you want to delete "'   obj.diagramlist{obj.diagramselection(index)} '/'   cname  '"'],'Delete curve'), 'Yes')
                
                cmanager.deleteCurve(cname, obj.session);
                obj.notify('diagramSelectionChanged' , CommanderModelEvent(1, obj.getCurveList(1)  , CommanderModelEvent.ADJUSTINDEX  ));
                obj.notify('diagramSelectionChanged' , CommanderModelEvent(2, obj.getCurveList(2)  , CommanderModelEvent.ADJUSTINDEX  ));

            end
            
        end
        function renameCurve(obj , index) 
            
            cmanager = getCurveManager(obj , index);
            list = getCurveList(obj, index);   
            cname = list{obj.curveselection(index)};
            %disp(['renaming: ' cname]);
            
               
                newname = inputdlg('Enter new curvename' , 'Rename Curve' , 1 , {cname});
                if (~isempty(newname))
                    [s,mess] = cmanager.renameCurve(cname , newname{1} , obj.session);
                    if (~s)
                       errordlg(mess, 'error'); 
                    end
                    obj.notify('diagramSelectionChanged' , CommanderModelEvent(1, obj.getCurveList(1)  , CommanderModelEvent.ADJUSTINDEX  ));
                    obj.notify('diagramSelectionChanged' , CommanderModelEvent(2, obj.getCurveList(2)  , CommanderModelEvent.ADJUSTINDEX  ));                    
                end            
        end

        function renameDiagram(obj,index)
            oldname = obj.diagramlist{obj.diagramselection(index)} ;
            newname = inputdlg('Enter new diagramname' , 'diagramname' , 1 , {oldname});
            if (~isempty(newname))
            if (ismember(newname{1} , obj.diagramlist))
                errordlg('diagramname already exists' , 'Error');
            else
                systempath = obj.system.getPath();
                
                [s,mess, misc] = movefile( [systempath '/' oldname] , [systempath '/' newname{1}] ,'f'); %FILES
                if (~s)
                    errordlg(mess, 'error');
                else
                    cm = obj.session.getCurveManager();
                    if (~isempty(cm) &&  strcmp(cm.diagrampath , [systempath '/' oldname]))
                        %disp('renamed current diagram!!');
                        cm.setPath([systempath '/' newname{1}]);
                        obj.session.notify('stateChanged');
                    end
                    
                end
                obj.reconfigure();
            end
            end
        end
        
        function deleteDiagram(obj,index)
            dname = obj.diagramlist{obj.diagramselection(index)} ;
            systempath = obj.system.getPath();
            if strcmp( questdlg(['Are you sure you want to delete the directory "'  dname  '"'],'Delete diagram'), 'Yes')
                [s, mess, messageid] = rmdir([systempath '/' dname],'s');  %FILES
                
                if (~s)
                    errordlg(mess, 'error');
                else
                    cm = obj.session.getCurveManager();
                    
                    
                    if (~isempty(cm) &&  strcmp(cm.diagrampath , [systempath '/' dname]))
                        % disp('deleted current diagram!!');
                        obj.session.reloadCurveManager();
                    end
                    
                    if (obj.diagramselection(1) > (length(obj.diagramlist) - 1)) %lists not yet updated
                        obj.diagramselection(1) = length(obj.diagramlist) - 1;
                    end
                    if (obj.diagramselection(2) > (length(obj.diagramlist) - 1)) %lists not yet updated
                        obj.diagramselection(2) = length(obj.diagramlist) - 1;
                    end                    
                    
                end
                obj.reconfigure();
                
            end
        end
        
        function newDiagram(obj,index)
            
           answer = inputdlg('Enter new diagramname' , 'diagramname');
           if (~isempty(answer))
                if (ismember(answer{1} , obj.diagramlist))
                    errordlg('diagramname already exists' , 'error');
                else
                    mkdir([obj.system.getPath() '/' answer{1}]);  %FILES
                    obj.reconfigure();
                end
           end            
        end
        function nr = getNrDiagrams(obj)
           nr = length(obj.diagramlist); 
        end
      
        function startDiagramPlot(obj,index , dimension)
            if (isempty(obj.diagrampreview{index}) || ~ishandle( obj.diagrampreview{index} ))
                cdp = CommanderDiagramPlot(obj.session , obj , index , dimension);
                obj.diagrampreview{index} = cdp.fig;
            end
            
        end
        function startCurvePlot(obj , index , dimension)
            if (isempty(obj.curvepreview) || ~ishandle(obj.curvepreview))
                ccp = CommanderCurvePlot(obj.session , obj , index , dimension);
                obj.curvepreview = ccp.fig;
            end
            
            
        end
        function viewCurve(obj, sideindex)
           if (obj.isValidCurve(sideindex))
               tablepreviews.previewPanel(  obj.getCurve(sideindex));
           end
            
        end
        
        
        
    end

    
    methods(Static)
        function manageCurrentDiagram(session)
           sys = session.getSystem();
           
            cm = CommanderModel(session , sys);
            
            if (session.windowmanager.isWindowOpen('browser'))
                session.windowmanager.closeWindow('browser');
            end
            fig = session.windowmanager.demandWindow('diagramorganizer');
            CommanderPanel(fig, cm);
            
            set(fig, 'Visible' , 'on' );%, 'WindowStyle' , 'modal');
            %FIXME: debug
            global commander
            commander = cm;
        end
        
    end
end


