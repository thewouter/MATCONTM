classdef InspectorCurve < handle
    %INSPECTORSYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        index
        label

        curvemanager
        previewdata
        passon
    end
    
    methods
        
        function obj = InspectorCurve(passon,path,label,curvemanager)
            obj.passon = passon;
            obj.label = label;

            if ~isempty(curvemanager)
               path = curvemanager.getPath(); 
            end
            
            
            cms = obj.passon.session.getCurveManager();
            if (isempty(cms) || ~strcmp(cms.getPath() , path))
                if isempty(curvemanager)
                    obj.curvemanager = CurveManager(obj.passon.session , path);
                else
                    obj.curvemanager = curvemanager;
                end

            else
                obj.curvemanager = cms;
            end
            
            if (obj.passon.preview)
               obj.previewdata = obj.curvemanager.getInfoList();
            end
            
        end
        function backOnTop(obj)
            printc(mfilename, 'backontop');
        end  
        function keypress(obj,e)  
            if strcmp(e.Key, 'delete')
                obj.delete_call();
            end            
        end        
        function list = getList(obj)
              list = obj.curvemanager.getCurveList()';
        end 
        
        function initIndex(obj)
            if isempty(obj.previewdata)
                obj.index = -1;
            else
                obj.index = 1;  
            end
        end          
        
        
        
        function bool = goUp(obj)
           bool = 1; 
        end
        function b = isValidSelection(obj)
           b = (obj.index > 0); 
        end
        
        function newobj = selectItem(obj,index) 
            passon = obj.passon;
            passon.curvemanager = obj.curvemanager;
            c = obj.curvemanager.getCurveByIndex(index);
            passon.curve = c;
            newobj = InspectorPoint(passon , c , c.getLabel());
            
        end
        function label = getLabel(obj)
            label = obj.label;
        end        
        function flist = getOperations(obj)
            flist{1} = cmdStruct(@() 'New'  ,    @() obj.createNewCurve() );
            
        end
        function flist = getItemOperations(obj)

            flist{1} = cmdStruct(@() 'Load'  , @() obj.loadCurve());
            flist{2} = cmdStruct(@() 'View'  , @() obj.previewPanel());
            flist{3} = cmdStruct(@() 'Rename', @() obj.rename_call());
            flist{4} = cmdStruct(@() 'Delete', @() obj.delete_call());

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
            list = obj.curvemanager.getCurveList();
            name = list{i};
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
            type = 3;
        end  
        function createNewCurve(obj)
            obj.passon.session.loadNewCurve( obj.passon.system, obj.curvemanager);
            obj.passon.killswitch();
            MainPanel.popupInput(obj.passon.session);
        end
        function previewPanel(obj)
            itemname = obj.currentItemName();
            curve = obj.curvemanager.getCurveByName(itemname);
            tablepreviews.previewPanel(curve);
        end
        
        function loadCurve(obj) 
            
            itemname = obj.currentItemName();
            
            Curve.installCurve(obj.passon.session  ,obj.passon.system ,  obj.curvemanager, itemname);

            obj.passon.killswitch();
            
            
            %MainPanel.popupInput(obj.passon.session);
            %disp('starter & continuer');
        end
        
        function rename_call(obj)
            if (obj.index > 0)
                oldname = obj.currentItemName();
                newname = inputdlg('Enter new curvename' , 'curvename' , 1 , {oldname});
                if (~isempty(newname))
                    
                    
                    [s,mess] = obj.curvemanager.renameCurve(oldname , newname{1} , obj.passon.session);
                    if (~s)
                       errordlg(mess, 'error'); 
                    end
                    
                    if (obj.passon.preview)
                        obj.previewdata = obj.curvemanager.getInfoList();
                    end
                    obj.passon.listreloaded();
                end
            end
        end
        function delete_call(obj)
            if (obj.index > 0)
                name =  obj.currentItemName();

                if strcmp( questdlg(['Are you sure you want to delete the curve "'  name  '"'],'Delete curve'), 'Yes')
                    
                    obj.curvemanager.deleteCurve(name, obj.passon.session);
                    len = obj.curvemanager.getNrOfCurves();
                    if (len == 0)
                        obj.index = -1;
                    elseif(obj.index > len)
                       obj.index = len; 
                    end
                        
                    if (obj.passon.preview)
                        obj.previewdata = obj.curvemanager.getInfoList();
                    end                    
                    
                    obj.passon.listreloaded();
                end
            end
            
        end
        function str = getToolTipString(obj)
            str = 'double-click to view points';
        end        
    end
    
    methods(Static)
       function curvelist = getCurveList(path)
            files = sortfiles(dir(path));
            names = {files.name};
            names = names(~[files.isdir]);
            ilist = strfind(names,'.mat');
            curvelist = {};
            for i = 1:length(ilist)
                if (~isempty(ilist{i}) && (ilist{i} == (length(names{i}) - 3)))
                    curvelist{end+1} = names{i}(1:(ilist{i}-1));
                end
            end
        end
    end
    
    
end


function s = cmdStruct(label, cmd)
    s = struct('label' , label , 'cmd' , cmd);
end
