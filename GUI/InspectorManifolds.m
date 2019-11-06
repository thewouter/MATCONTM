classdef InspectorManifolds < handle
    %INSPECTORSYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        passon
        manifoldcollection
        index
        
        selectFunction;
    end
    
    methods
        
        function obj = InspectorManifolds(passon , manifoldcollection , selectFunction)
            obj.passon = passon;
            obj.manifoldcollection = manifoldcollection;
            obj.selectFunction = selectFunction;
            
        end
       
        function backOnTop(obj)
           printc(mfilename,'backontop'); 
        end
        
        
        function list = getList(obj)
                list = obj.manifoldcollection.getManifoldList();
        end
        
        function bool = goUp(obj)
           bool = 0; 
        end
        function b = isValidSelection(obj)
           b = (obj.index > 0); 
        end
        function newobj = selectItem(obj,index) 
            obj.selectFunction( obj.manifoldcollection.getByIndex(index));
            
            newobj = [];
            obj.passon.killswitch();
        end
        
        function keypress(obj,e)          
        end    
        
        
        function label = getLabel(obj)
            label = 'Manifold list';
        end
        function flist = getOperations(obj)
               flist = {};
        end

        function flist = getItemOperations(obj)
           flist{1} = cmdStruct( @() ['Delete "'  obj.getSelectedName()  '"    '] , @() obj.deleteCurrManifold()); 
           flist{2} = cmdStruct( @() ['Plot  "'  obj.getSelectedName()  '"    '] , @() obj.plotManifold());
        end
        
        
        
        function flist = getInheritedOperations(obj)
           flist = {}; 
        end

        function deleteCurrManifold(obj)
            if (obj.index > 0)
                obj.manifoldcollection.delManifoldByIndex(obj.index);
                obj.index = obj.index - 1;
                obj.passon.listreloaded();
            end
        end
        
        function plotManifold(obj)
	    global mp;
            mp = ManifoldsPlot(obj.passon.session);
            mp.addManifold(obj.manifoldcollection.getByIndex(obj.index));
            mp.setupPlot();
        end
            
        
        
        function data = getPreviewData(obj)
            data = 'previewdata';
        end
        
        function s = getSelectedName(obj)
            if (obj.index > 0)
                mani = obj.manifoldcollection.getByIndex(obj.index);
                s = mani.name;
            else
                s = '                              ';
            end
            
        end
        
        function data = getSelectedPreviewData(obj) 

            if (obj.index > 0)
                data =  obj.manifoldcollection.getByIndex(obj.index);
            else
                data = [];
            end
        end
        
        function type = getType(obj)
            type = 5;
        end
        

         function str = getToolTipString(obj)
            str = 'double-click to select a manifold';
        end       
    end

    
    
    methods(Static)
        function selectAManifold(session , manifoldcollection , manifoldSelectedfunction)
            im = InspectorModel(session);
            passon.preview = true;
            passon.session = session;
            passon.killswitch = @() im.shutDown();
            passon.listreloaded = @() im.notify('listChanged');
            passon.im = im;
            
            im.current = InspectorManifolds(passon , manifoldcollection , manifoldSelectedfunction);
            im.current.index = -1;
            InspectorPanel.startWindowWoPath( session.getWindowManager(), im , 'browser2')
        end
    end

end

function s = cmdStruct(label, cmd)
    s = struct('label' , label , 'cmd' , cmd);
end

