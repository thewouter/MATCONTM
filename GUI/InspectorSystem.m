classdef InspectorSystem < handle
    %INSPECTORSYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        index
        systempath
        list
        label
        previewdata = [];  %DO mem cleanup after
        
        passon
    end
    
    methods
        
        function obj = InspectorSystem(passon,path,label)
            obj.label = label;
            obj.systempath = path;
            obj.passon = passon;
            obj.setUp();
                     
        end
        
        function setUp(obj)
            obj.list = InspectorSystem.getSystemList(obj.systempath);
            if (obj.passon.preview)
                obj.previewdata = cell(1,length(obj.list));
                for i = 1:length(obj.list)
                   obj.previewdata{i} =  SystemSpace.loadSystem(obj.passon.session, obj.list{i});
                end

                
            end
            len = length(obj.list);
            
            if (len == 0)
                obj.index = -1;
            elseif (obj.index > len)
                obj.index = len;
            end
        end
        function reSet(obj)
            len = length(obj.list);
            if (len == 0)
                obj.index = -1;
            elseif (obj.index > len)
                obj.index = len;
            end            
            
        end
        
        
        function list = getList(obj)
              list = obj.list;
        end
        
        function bool = goUp(obj)
            %disp('begining of the line');
           bool = 0; 
        end

        function newobj = selectItem(obj,index) 
            passon = obj.passon;
            passon.system = SystemSpace.loadSystem(obj.passon.session , obj.list{index});
            newobj = InspectorDiagram(passon, [obj.systempath  '/' obj.list{index}], obj.list{index});
        end
        
        function name = getItemName(obj,index)
            name = obj.list{index};
        end
        
        function name = currentItemName(obj)
            if (obj.index < 0)
                i = 1;
            else
                i = obj.index; 
            end
            name = obj.list{i};
        end
        function b = isValidSelection(obj)
           b = (obj.index > 0); 
        end
        
        function label = getLabel(obj)
            label = obj.label;
        end
        
        function flist = getOperations(obj)
            flist{1} = cmdStruct(@() 'New' , @() obj.new_system_call());
        end
        
        function flist = getItemOperations(obj)
            flist{1} = cmdStruct(@() 'Load'  ,    @()  obj.load_system_call());
            flist{2} = cmdStruct(@() 'Delete'  ,    @()  obj.delete_system_call());
            flist{3} = cmdStruct(@() 'Edit'  ,    @()  obj.edit_system_call());
            flist{4} = cmdStruct(@() 'Add/Edit Userfunctions'  ,    @()  obj.edit_uf_call());
        end
        
        function flist = getInheritedOperations(obj)
           flist = {}; 
        end
        
        function data = getPreviewData(obj)
            data = obj.previewdata;
        end
        
        function initIndex(obj)
            obj.index = -1;
            
            for i = 1:length(obj.previewdata)
                if strcmp(obj.previewdata{i}.getName() , obj.passon.session.getSystem().getName())
                    obj.index = i;
                    return;
                end
            end
        end
        
        function data = getSelectedPreviewData(obj) %gevaarlijker
            if (obj.passon.preview && (obj.index >= 1))
                data = obj.previewdata{obj.index};
            else
                data = [];
            end
           
        end
        function type = getType(obj)
            type = 1;
        end
              
        function backOnTop(obj)
           printc(mfilename , 'backontop'); 
        end
        
        function new_system_call(obj)
            obj.passon.killswitch();
            MainPanel.newsystem(obj.passon.session);
        end
        
        function load_system_call(obj)
            sys = obj.previewdata{ obj.index };
            obj.passon.session.loadNewCurve(sys , CurveManager(obj.passon.session, sys.getDefaultDiagramPath()));
            obj.passon.killswitch();
            MainPanel.popupInput(obj.passon.session);
        end
        
        function edit_uf_call(obj) %FIXME: session meegeven, zeker bug
            sys = obj.previewdata{ obj.index };
            global session;
            SystemSpace.userfunctionsEdit(session , sys);
            % % %
            if (sys.cmp(obj.passon.session.getSystem()))
		obj.passon.session.system = SystemSpace.loadSystem(  obj.passon.session ,    sys.getPath()); %reload
		obj.passon.session.warnObservers('newSystem');
            end
            obj.setUp();
            obj.passon.listreloaded();            
        end
        
        function delete_system_call(obj)
            
            sys = obj.previewdata{ obj.index };
            path = sys.getPath();
            
            if strcmp( questdlg(['Are you sure you want to delete the system "'  sys.getName() '"'],'Delete system'), 'Yes')
                [s, mess, messageid] = rmdir( path ,'s');
                if (~s)
                    errordlg(mess, 'error');
                else
                    delete([path '.mat']);
                    delete([path '.m']);
                    %conflict check:
                    if (sys.cmp( obj.passon.session.getSystem() ))
                       obj.passon.session.reSet();
                    end
                obj.list(obj.index) = [];
                obj.previewdata(obj.index) = [];
                obj.reSet();
                obj.passon.listreloaded();
                end
                
            end
            
            %...

        end
        
        function edit_system_call(obj)
            sys = obj.previewdata{ obj.index };
                
            warndlg('Altering a system could make older curvedata uninterpretable. Edited systems with added parameters and no rearranging can still be loaded'  ,'Edit System');

            newsys = SystemSpace.editSystem(obj.passon.session, sys);
            
            if (~isempty(newsys))
                if (newsys.cmp( obj.passon.session.getSystem()))
                   obj.passon.session.system = newsys;
                    obj.passon.session.warnObservers('newSystem'); 
                end

                obj.setUp();
                obj.passon.listreloaded();
            end
        end
        function str = getToolTipString(obj)
            str = 'double-click to view diagrams';
        end
        
        function keypress(obj,e)
            if strcmp(e.Key, 'delete')
                obj.delete_system_call()
            end          
        end
    end
    
    methods(Static)
        function syslist = getSystemList(syspath)
            files = dir(syspath);
            names = {files.name};
            ilist = strfind(names,'.mat');
            syslist = {};
            for i = 1:length(ilist)
                if (~isempty(ilist{i}) && (ilist{i} == (length(names{i}) - 3)))
                    sysname = names{i}(1:(ilist{i}-1));
                    if (ismember([sysname '.m'] , names))
                        syslist{end+1} = sysname;
                    end
                end
                
            end
        end        
    end
    
end
function s = cmdStruct(label, cmd)
    s = struct('label' , label , 'cmd' , cmd);
end

