classdef InspectorConOrbits < handle
    %INSPECTORSYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        conorbitscol;
        passon;
        selectFunction;
        index = -1;
    end
    
    methods
        
        function obj = InspectorConOrbits(passon , conorbitscol , selectFunction)
            obj.passon = passon;
            obj.conorbitscol = conorbitscol;
            obj.selectFunction = selectFunction;
            
        end
        
        function backOnTop(obj)
            printc(mfilename,'backontop');
        end
        
        
        function strlist = getList(obj)
            len = obj.conorbitscol.getLength();
      
            strlist = cell(1,len);
            for i = 1:len
                strlist{i} = obj.conorbitscol.get(i).toString();
            end
            
        end
        
        function bool = goUp(obj)
            bool = 0;
        end
        function b = isValidSelection(obj)
            b = (obj.index > 0);
        end
        
        function newobj = selectItem(obj,index)
            obj.selectFunction( obj.conorbitscol.get(index)  );
            newobj = [];
            obj.passon.killswitch();
        end
        
        function keypress(obj,e)
        end
        
        
        function label = getLabel(obj)
            label = 'Connecting Orbits list';
        end
        function flist = getOperations(obj)

            flist{1} = cmdStruct( @() 'Add Orbit from MATLAB workspace' , @() obj.addFromMatlab());
        end
        
        function flist = getItemOperations(obj)
            flist{1} = cmdStruct( @() ['Select Orbit'] , @()  obj.selectItem(obj.index) );
            flist{2} = cmdStruct( @() ['Delete Orbit'] , @() obj.deleteCurrent());
            
        end
        
        
        function flist = getInheritedOperations(obj)
            flist = {};
        end
        
        
        function addFromMatlab(obj)
            
            answ =inputdlg({'MATLAB workspace variable name or expression:'},'Enter Orbit from MATLAB workspace',1,{''});
            if (isempty(answ))
               return; 
            end
            evalstr = strtrim(answ{1});
            if (isempty(evalstr))
                return;
            end
            
            try 
                c = evalin('base' , evalstr);
                if (~ismatrix(c) || ~isnumeric(c))
                    errordlg('Not a valid matrix' , 'Expression Failed!')
                   return; 
                end
                dim = obj.passon.session.getSystem().getNrCoordinates();
                
                if (size(c,1) ~= dim)
                   c = c';
                   if (size(c,1) ~= dim)
                       errordlg('Dimension mismatch' , 'Expression Failed!')
                      return; 
                   end
                    
                end
                %%% ADD from MATLAB
                
                obj.index = obj.conorbitscol.addOrbit(  ConnectingOrbitCustom(c , evalstr) );
                obj.passon.listreloaded();
            
            catch error
                errordlg( error.message , 'Expression Failed!');
                disp(error);
            end
            
        end
        
        
        
        function deleteCurrent(obj)
            obj.conorbitscol.delOrbit(obj.index);
            if (obj.index > obj.conorbitscol.getLength())
               obj.index =  obj.conorbitscol.getLength();
            end
            obj.passon.listreloaded();
        end
        
        function data = getPreviewData(obj)
            data = 'previewdata';
        end
        
        function data = getSelectedPreviewData(obj)
            
            if (obj.index > 0)
                data = obj.conorbitscol.get(obj.index);
            else
                data = [];
            end
        end
        
        function type = getType(obj)
            type = 6;
        end
        
        
        function str = getToolTipString(obj)
            str = 'double-click to select a connecting orbit';
        end
    end
    
    
    
    methods(Static)
        function selectAConOrbit(session , conorbcol , orbitSelectedfunction)
            im = InspectorModel(session);
            passon.preview = true;
            passon.session = session;
            passon.killswitch = @() im.shutDown();
            passon.listreloaded = @() im.notify('listChanged');
            passon.im = im;
            
            im.current = InspectorConOrbits(passon , conorbcol , orbitSelectedfunction);
            im.current.index = -1;
            InspectorPanel.startWindowWoPath( session.getWindowManager(), im , 'browser2');
        end
    end
    
end

function s = cmdStruct(label, cmd)
s = struct('label' , label , 'cmd' , cmd);
end

