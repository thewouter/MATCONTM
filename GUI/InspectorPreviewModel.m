classdef InspectorPreviewModel < handle
    %INSPECTORPREVIEWMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        session
        
        inspectormodel
        current
        
        
        eventlistener = {}
        info = [];
        
        index = -1;
    end
    
    events
        previewTypeChanged
        selectionChanged
        
        %dead events:
        listChanged
        indexChanged
    end
    
    methods
        function obj = InspectorPreviewModel(session, inspectormodel)
            obj.session = session;
            obj.inspectormodel = inspectormodel;
            obj.eventlistener{1} = inspectormodel.addlistener('indexChanged', @(o,e) obj.onIndexChanged(obj.current));
            obj.eventlistener{2} = inspectormodel.addlistener('listChanged', @(o,e) obj.onListChanged(inspectormodel));
            
            obj.onListChanged(inspectormodel);
        end
        
        function onIndexChanged(obj,currentmodel)
            obj.info = currentmodel.getSelectedPreviewData();
            %disp(obj.info);
            obj.notify('selectionChanged');
        end
        function onListChanged(obj,inspectormodel)
            obj.current = inspectormodel.getCurrent();
            obj.notify('previewTypeChanged');
            obj.onIndexChanged(obj.current);
        end    
        
        function info = getInfoObject(obj)
            info = obj.info;
        end
        
        function type = getType(obj)
            type = obj.current.getType();
        end
        
        function setSelectedIndex(obj, index)
            obj.index = index;
        end
        
        function i = getSelectedIndex(obj)
            i = obj.index;
        end
        
        function list = getSelectList(obj)
            list = obj.info;
        end
        function n = getNrElements(obj)
            n = length(obj.info);
        end
        function unSetIndex(obj)
            obj.index = -1;
        end
        function selectItem(obj, index)
        end
        function goUp(obj)
        end
        function it = getSelectedItemName(obj)
            it = '';
        end
    end
    
end

