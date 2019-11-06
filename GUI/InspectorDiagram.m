classdef InspectorDiagram < handle
    %INSPECTORSYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        index
        diagrampath
        list
        label
        
        passon;
        previewdata = [];
    end
    
    methods
        
        function obj = InspectorDiagram(passon , path,label)
            obj.label = label;
            obj.diagrampath = path;
            
            obj.passon = passon;
            
            obj.initialise();
        end

        function keypress(obj,e)   
            if strcmp(e.Key, 'delete')
                obj.delete_call()
            end
        end        
        function initialise(obj)
            obj.list = InspectorDiagram.getDiagramList(obj.diagrampath);
            if (obj.passon.preview)
                obj.previewdata = cell(1,length(obj.list));
                for i = 1:length(obj.list)
                    obj.previewdata{i} = CurveManager.getCurveNamesList([obj.diagrampath '/' obj.list{i}] );
                end
            end
            len = length(obj.list);
            
            if (len == 0)
                obj.index = -1;
            elseif (obj.index > len)
               obj.index = len; 
            end
            
        end
        
        function initIndex(obj)
            if isempty(obj.list)
                obj.index = -1;
            else
                obj.index = 1;
            end
        end    
        
        function list = getList(obj)
              list = obj.list;
        end
        
        function bool = goUp(obj)
           bool = 1; 
        end
        function b = isValidSelection(obj)
           b = (obj.index > 0); 
        end
        function newobj = selectItem(obj,index) 
            passon = obj.passon;
            passon.diagram = obj.list{index};
            
            newobj = InspectorCurve( passon , [obj.diagrampath '/' obj.list{index}],obj.list{index} , []);
        end
        
        
        function label = getLabel(obj)
            label = obj.label;
        end
        function flist = getOperations(obj)
            flist{1} = cmdStruct(@() 'New' , @() obj.createNew());
        end
        function flist = getItemOperations(obj)
            flist{1} = cmdStruct(@() 'Load'  ,    @()  obj.load_call());
            flist{2} = cmdStruct(@() 'Rename',    @()  obj.rename_call());
            flist{3} = cmdStruct(@() 'Delete',    @()  obj.delete_call());
        end
        function flist = getInheritedOperations(obj)
           flist = {}; 
        end
        function name = currentItemName(obj)
            if (obj.index < 0)
                i = 1;
            else
                i = obj.index; 
            end
            name = obj.list{i};
        end
        
        
        function data = getPreviewData(obj)
            data = obj.previewdata;
        end
        function data = getSelectedPreviewData(obj) %gevaarlijker
            
            if (obj.passon.preview && (obj.index >= 1))
                data = obj.previewdata{obj.index};
            else
                data = [];
            end
        end
        function type = getType(obj)
            type = 2;
        end   
        function backOnTop(obj)
            obj.initialise();
            printc(mfilename, 'backontop');
        end
        
  
        
        function createNew(obj)
           answer = inputdlg('Enter new diagramname' , 'diagramname');
           if (~isempty(answer))
                if (ismember(answer{1} , obj.list))
                    errordlg('diagramname already exists' , 'error');
                else
                    mkdir([obj.diagrampath '/' answer{1}]);
                    obj.initialise();
                    obj.passon.listreloaded();
                end
           end
           
        end
        
        function rename_call(obj)
            if (obj.index > 0)
                oldname = obj.currentItemName();
                newname = inputdlg('Enter new diagramname' , 'diagramname' , 1 , {oldname});
                if (~isempty(newname))
                if (ismember(newname{1} , obj.list))
                    errordlg('diagramname already exists' , 'error');
                else
                    [s,mess, misc] = movefile( [obj.diagrampath '/' oldname] , [obj.diagrampath '/' newname{1}] ,'f');
                    if (~s)
                       errordlg(mess, 'error'); 
                    else
                       cm = obj.passon.session.getCurveManager();
                       if (~isempty(cm) &&  strcmp(cm.diagrampath , [obj.diagrampath '/' oldname]))
                           %disp('renamed current diagram!!');
                           cm.setPath([obj.diagrampath '/' newname{1}]);
                           obj.passon.session.notify('stateChanged');
                       end
                    end
                    obj.initialise();
                    obj.passon.listreloaded();
                end
                end
            end
        end
        function delete_call(obj)
            if (obj.index > 0)
                name =  obj.currentItemName();
                
                
                if strcmp( questdlg(['Are you sure you want to delete the directory "'  name  '"'],'Delete diagram'), 'Yes')
                    [s, mess, messageid] = rmdir([obj.diagrampath '/' name],'s');
                    if (~s)
                        errordlg(mess, 'error');
                    else
                        cm = obj.passon.session.getCurveManager();
                       if (~isempty(cm) &&  strcmp(cm.diagrampath , [obj.diagrampath '/' name]))
                          % disp('deleted current diagram!!');
                           obj.passon.session.reloadCurveManager();
                       end
                    obj.initialise();
                    obj.passon.listreloaded();
                    end

                end
            end
            
        end
        function load_call(obj)
            if (obj.index > 0)
                path = [obj.diagrampath '/' obj.currentItemName()];
                obj.passon.session.loadNewCurve( obj.passon.system, CurveManager(obj.passon.session, path));
                obj.passon.killswitch();
                MainPanel.popupInput(obj.passon.session);
            end
        end
        
         function str = getToolTipString(obj)
            str = 'double-click to view curves';
        end       
    end
    
    methods(Static) 
        function diagramlist = getDiagramList(path)
            files = sortfiles(dir(path));
            names = {files.name};
            names = names([files.isdir]);
            
            diagramlist = {};
            
            for i = 1:length(names)
                if ~strcmp(names{i}(1) , '.')
                    diagramlist{end+1} = names{i};
                end
            end
        end
    end
    
end

function s = cmdStruct(label, cmd)
    s = struct('label' , label , 'cmd' , cmd);
end




