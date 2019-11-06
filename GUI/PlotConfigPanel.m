classdef PlotConfigPanel
    %PLOTCONFIGPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dimension;
        panelhandle;
        plotconf;
        
        regionLeftHandle
        regionRightHandle
        
        subsectionnode
        mainnode

       % mainpanel
        
        selectionlist
    end
    
    
    methods
        function obj = PlotConfigPanel(parent , plotconf , dim  ,varargin)
            obj.plotconf = plotconf;
            obj.dimension = dim;
            %obj.mainpanel = mainpanel;
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixel' ,'Title' , plotconf.getAxTitle(dim)  ,...
                'DeleteFcn' , @(o,e) obj.destructor() , varargin{:});
            
            mainnode = LayoutNode(-1,-1, 'vertical');
            obj.mainnode = mainnode;
            
            subnode = LayoutNode(1,0);
            
            obj.subsectionnode = LayoutNode(0,2);
            subnode.addNode(obj.subsectionnode);
            
            listid = plotconf.initSelection( obj.dimension ,obj.panelhandle , obj.subsectionnode);
            obj.selectionlist = plotconf.getSelectionList();
            index =  getIndex(listid, obj.selectionlist  );
		
            subnode.addHandle(0,1,  uicontrol(obj.panelhandle , 'Units', 'Pixels' , 'Style' , 'popupmenu' ...
                , 'string' , obj.selectionlist , 'Value' , index , 'Callback' , @(o,e) obj.sectionPopupCallback(o,e)   ), 'minsize' , [Inf 20] , 'margin', [5 5]);
            
            mainnode.addNode(subnode);
            subnode = LayoutNode(1,0);
            subnode.addHandle(0,1,uicontrol(obj.panelhandle, 'Units','Pixels', 'Style' , 'text' , 'String' , 'Range:'));

            [l,r] = plotconf.getRegion(obj.dimension);
            obj.regionLeftHandle = uicontrol(obj.panelhandle, 'Units','Pixels', 'Style'  , 'edit' , 'String' , num2str(l , '%.16g')  , 'Callback' ,@(o,e) regionChangeCallback(plotconf) );
            obj.regionRightHandle = uicontrol(obj.panelhandle, 'Units','Pixels', 'Style'  , 'edit' , 'String' , num2str(r, '%.16g')   , 'Callback' ,@(o,e) regionChangeCallback(plotconf));
            
            subnode.addHandle(0,2,obj.regionLeftHandle, 'minsize' , [Inf 20] , 'margin' , [5,5]);
            subnode.addHandle(0,1,uicontrol(obj.panelhandle,'Units','Pixels', 'Style' , 'text' , 'String' , '...' , 'Fontsize' ,13));
            subnode.addHandle(0,2,obj.regionRightHandle, 'minsize' , [Inf 20], 'margin' , [5,5]);
            
            mainnode.addNode(subnode);
            
            
            
            data.extentfunction = @() obj.getExtent();
            data.node = obj.mainnode;
            set(obj.panelhandle , 'UserData' , data);
            
            
            set(obj.panelhandle, 'ResizeFcn' , @(o,e) obj.doLayout());
            obj.doLayout();
        end
        

        function [left , right] = getRegion(obj)
           left =  str2double(get(obj.regionLeftHandle, 'String'));
           right=  str2double(get(obj.regionRightHandle, 'String'));

        end
        function setRegion(obj, left, right)
           set( obj.regionLeftHandle, 'String' , num2str(left, '%.16g'));
           set( obj.regionRightHandle,'String' , num2str(right,'%.16g'));
        end
        
        function destructor(obj)
           delete(obj.mainnode); 
        end

        function sectionPopupCallback(obj,handle,e)
            val = get(handle , 'Value');
            obj.subsectionnode.makeEmpty();
            obj.plotconf.setSelectionById(obj.dimension , obj.selectionlist{val} , obj.panelhandle , obj.subsectionnode);
            %
            obj.plotconf.rebuildGraph();
            %
            obj.doLayout();
        end
        function [w,h] = getExtent(obj)
            [w,h] = obj.mainnode.getPrefSize();
            h = h + 20;
            w = w + 4;
        end
        
        
        function doLayout(obj)
            units = get(obj.panelhandle, 'Units');
          
            set(obj.panelhandle,'Units', 'Pixels');
            pos = get(obj.panelhandle, 'Position');
            if ~isempty(pos)
                pos(4) = max(pos(4) - 10,1);
                obj.mainnode.makeLayoutHappen(pos);
            end
            set(obj.panelhandle,'Units',units);
        end
        
    end
    
    
end

function i = getIndex(item , list)
	i = 1;
	len = length(list);

	while(i < len)
		if (strcmp(item , list{i})), return; end;
		i = i + 1;
	end

end
        
        
function regionChangeCallback(plotconf)
    printc(mfilename , 'REGIONCHANGED CALLBACK:  setAUTOFIT: false');
    plotconf.setAutoFit(false);
    plotconf.rebuildGraph();
end
