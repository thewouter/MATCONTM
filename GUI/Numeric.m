classdef Numeric < handle
    %NUMERIC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        selectedList = struct('coordinates', 1 ,'parameters' , 1,'testfunctions', 1, 'multipliers' , 1 ,'current_stepsize' , 1 , 'user_functions' , 1 , 'npoints' , 1);
        allowedList;
        handleList;
        startdata
        
        panelhandle;
        bgColor = [0.95 0.95 0.95];
        mainnode = [];
    end
    
    events
        selectionChanged;
    end
    
    methods
        function obj = Numeric(session, uiparent, embed ,  varargin)
            system = session.getSystem();
            curvetype = session.getCurveType();
            obj.startdata =  session.getStartData();
            
            
%            obj.startdata.addlistener('structureChanged' ,  @(o,e) obj.changed(session));
%            obj.startdata.addlistener('settingChanged' ,  @(o,e) obj.changed(session));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.configureLists(system , curvetype);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.panelhandle = uipanel(uiparent, 'Unit' , 'Pixels' , 'BackgroundColor' , obj.bgColor , varargin{:});
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor() , 'ResizeFcn' , @(o,e) obj.onResize(o));
            
            if (embed)
                pos = get(uiparent , 'Position');
                set(obj.panelhandle ,'Position' ,[0 0 pos(3) pos(4)]);
            end
            
            obj.createHandles(obj.panelhandle);
            obj.organizePanel();
            
            if (embed)
                set(obj.panelhandle , 'Units' , 'normalize');
                NumericOptionMenu( uiparent , obj );
            end
          
            
        end
        
        function changed(obj,session)
           printc(mfilename, 'changed: reloading'); 
           system = session.getSystem();
           curvetype = session.getCurveType();
           obj.configureLists(system,curvetype); 
           obj.reorganizePanel();
           obj.notify('selectionChanged');
        end       
        
        function selectionEvent(obj)
            obj.softreorganizePanel();
            obj.notify('selectionChanged');
            
        end
        
        function configureLists(obj, system ,curvetype)
            printc(mfilename, 'configureLists');
            
        
            
            %FIXME:  handles proper verwijderen , of via een paneldestruct
            %? 
            obj.handleList = struct();
            
            coordlist = system.getCoordinateList();
            obj.handleList.coordinates = struct();
            for i = 1:length(coordlist)
                obj.handleList.coordinates.(coordlist{i}) = -1;
            end
            
            paramlist = system.getParameterList();
            obj.handleList.parameters = struct();
            for i = 1:length(paramlist)
                obj.handleList.parameters.(paramlist{i}) = -1;
            end

            obj.handleList.multipliers = struct();
            for i = 1:length(coordlist)
                obj.handleList.multipliers.(['mod_' num2str(i)]) = -1;
            end
            for i = 1:length(coordlist)
                obj.handleList.multipliers.(['arg_' num2str(i)]) = -1;
            end           
            
            
            testlist = curvetype.getTestfunctions();
            obj.handleList.testfunctions = struct();
            for i = 1:length(testlist)
                obj.handleList.testfunctions.( testlist{i} ) = -1 ;
            end
            
       
            obj.handleList.user_functions = struct(); %
            %
            if (~isempty(obj.startdata))
                ufnr = obj.startdata.getNrUserfunctions();
                for i = 1:ufnr
                      if (  obj.startdata.isValidUserfunction(i) )
                          obj.handleList.user_functions.(obj.startdata.getLabelUserfunction(i)) = -1;
                      end 
                end
            end
            
            obj.handleList.npoints = -1;
            obj.handleList.current_stepsize = -1;
  
            %obj.selectedList = struct('coordinates', 1 ,'parameters' , 1,'testfunctions', 1, 'multipliers' , 1 ,'current_stepsize' , 1 , 'user_functions' , 1 , 'npoints' , 1);
            obj.allowedList = struct('coordinates', 0 ,'parameters' , 0,'testfunctions', 0, 'multipliers' , 0 ,'current_stepsize' , 0 , 'user_functions' , 0 , 'npoints' , 0);
            varsenabled  = curvetype.getNumericVarList();
            for i = 1:length(varsenabled)  %ToFix...  bijhouden per curvetype |||  session ?
                obj.allowedList.(varsenabled{i}) = obj.isSectionNonEmpty(varsenabled{i});
            end
%             fieldlist = fieldnames(obj.selectedList);
%             for i = 1:length(fieldlist)
%                 obj.selectedList.(fieldlist{i}) = obj.selectedList.(fieldlist{i}) &&  obj.allowedList.(fieldlist{i});
%             end                
            
            
            
            
            
        end
        function setSectionEnabled(obj , keyword , bool)
            
            if (obj.allowedList.(keyword) && obj.selectedList.(keyword) ~= bool)
                obj.selectedList.(keyword) = bool;
                obj.selectionEvent();
            end 
        end
        function bool = isSectionEnabled(obj, keyword)
            bool = obj.allowedList.(keyword) && obj.selectedList.(keyword);
        end 
        
        function bool = isSectionAllowed(obj , keyword)
            bool = obj.allowedList.(keyword);
        end
        
        function list =  getSectionList(obj)
            list = fieldnames(obj.selectedList);
        end
        function h = getHandle(obj , key , varargin)
           if (isstruct(obj.handleList.(key)))
                h = obj.handleList.(key).(varargin{1});
           else
               h = obj.handleList.(key);
           end
            
        end
        function list = getSubSections(obj , keyword)
            list = fieldnames(obj.handleList.(keyword));
        end
        
        function copyOver(obj,numdata)
            obj.selectedList = numdata.selectedList;
            obj.selectionEvent();
            
        end
        
        function A = saveobj(obj)
            A.selectedList = obj.selectedList;
        end

        function list = getAllowedSections(obj)
            list = {};
            fieldlist = fieldnames(obj.selectedList);
            for i = 1:length(fieldlist)
                if ( obj.isSectionDisplayable(fieldlist{i}))
                    list{end+1} = fieldlist{i};
                end
            end
        end
        
        function bool = isSectionDisplayable(obj, keyword)
            bool =  obj.allowedList.(keyword) && obj.selectedList.(keyword);
        end
        
        function bool = isSectionNonEmpty(obj , keyword)
            bool =  true;
            if (ismember(keyword , {'testfunctions' , 'user_functions' , 'multipliers' } ))
                subkeys = fields(obj.handleList.(keyword));
                
                for i = 1:length(subkeys)
                    if (isFieldEnabled(obj, keyword , subkeys{i}))
                        return
                    end
                end
                bool = false;
                return;
            else
               return; 
            end
        end           
        
        function b = isFieldEnabled(obj , key, subkey)
            b = true;
            if (isempty(obj.startdata)), return; end  %FIXME: embed hack ?
            
            switch (key)
                case 'testfunctions'
                    b = obj.startdata.getMonitorSingularities(subkey);
                    return
                    
                case 'user_functions'
                    b = obj.startdata.isEnabledUserfunction(obj.startdata.getUserFunctionIndex(subkey));
                    return
                case 'multipliers'
                    b = obj.startdata.getMultipliers();
                    return

                otherwise
                    return
                    
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function createHandles(obj , parentpanel)
            
            list = fieldnames(obj.handleList);
            for i = 1:length(list)
               if (isstruct(obj.handleList.(list{i})))
                    sublist = fieldnames(obj.handleList.(list{i}));
                    for j = 1:length(sublist)
                        obj.handleList.(list{i}).(sublist{j}) = uicontrol(parentpanel , 'Visible' , 'off');
                    end
               else
                   obj.handleList.(list{i}) = uicontrol(parentpanel , 'Visible' , 'off');
               end
            end
        end      
        
        function checkHandles(obj)
            
            list = fieldnames(obj.handleList);
            for i = 1:length(list)
               if (isstruct(obj.handleList.(list{i})))
                    sublist = fieldnames(obj.handleList.(list{i}));
                    for j = 1:length(sublist)
                        if (~ ishandle(obj.handleList.(list{i}).(sublist{j})))
                           error('CORRUPT HANDLELIST');
                           
                        end
                    end
               else
                   if (~ishandle(obj.handleList.(list{i})))
                       error('CORRUPT HANDLELIST');
                       
                   end
               end
            end
        end               
        
        
        function moveHandles(obj , parentpanel)
            list = fieldnames(obj.handleList);
            for i = 1:length(list)
               if (isstruct(obj.handleList.(list{i})))
                    sublist = fieldnames(obj.handleList.(list{i}));
                    for j = 1:length(sublist)
                        set(obj.handleList.(list{i}).(sublist{j}) , 'Parent' , parentpanel , 'Visible' , 'off');
                    end
               else
                   set(obj.handleList.(list{i}),'Parent' , parentpanel , 'Visible' , 'off');
               end
            end            
            
        end
        
        
        function softreorganizePanel(obj)
            printc(mfilename, 'softreorganize');
            %HHHHHHHAAAAAAAAAAXXXXXXXX FIXME
            %TODO: zoek code die alle panels opspeurt en dan delete, dan
            %alles ok
            dummy = figure('Visible' , 'off');
            obj.moveHandles( dummy );
            list = allchild(obj.panelhandle); 
            delete(list);
            obj.moveHandles( obj.panelhandle );
            obj.mainnode.destructor(); obj.mainnode = 0;
            
            units = get(obj.panelhandle , 'Units');
            set(obj.panelhandle ,'Units' , 'Pixels');
            obj.organizePanel();
            set(obj.panelhandle  ,'Units' , units);             
            
        end
        
        
        function reorganizePanel(obj)
            
            printc(mfilename, 'hardreorganize');
            if ~isempty(obj.panelhandle); delete(allchild(obj.panelhandle)); end;
            obj.createHandles(obj.panelhandle);
            
            obj.mainnode.destructor(); obj.mainnode = 0;
            
            units = get(obj.panelhandle , 'Units');
            set(obj.panelhandle ,'Units' , 'Pixels');
            obj.organizePanel();
            set(obj.panelhandle  ,'Units' , units);           
        end


        function onResize(obj,handle)
            units = get(handle , 'Units');
            set(handle,'Units' , 'Pixels');
            pos = get(handle, 'Position');

            if ((~isempty(pos)) && ~isempty(obj.mainnode)) 
                obj.mainnode.makeLayoutHappen(pos);
            end
            set(handle,'Units' , units);
        end 
        
        function organizePanel(obj)
            printc(mfilename , 'organizePanel');
            mainnode = LayoutNode(-1 , -1 , 'vertical');

            selected = obj.getAllowedSections();
            
            miscpanel  = Panel(obj.panelhandle , 0 ,  0 , 'BackgroundColor' , obj.bgColor );
            
            
            for i = 1:length(selected)
                sectionnode = LayoutNode( 0 , 0 , 'vertical');
                
                if (isstruct( obj.handleList.(selected{i})))
                    keys = fieldnames(obj.handleList.(selected{i}));
                    if (~isempty(keys))
                    sectionnode.setWeights( 4*length(keys) , 1);
                    panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , obj.bgColor , 'Title', selected{i});
                    sectionnode.addGUIobject(1,1,panel);
                    
                    
                    for j = 1:length(keys)
                        
                        if (obj.isFieldEnabled(selected{i} ,keys{j}))
                            subnode = LayoutNode( 2 , 1);
                            subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , obj.bgColor , 'HorizontalAlignment' , 'left' , ...
                        'FontSize', 12, 'String' ,  keys{j} ), 'minsize' , [Inf,20]);
                            handle = obj.handleList.(selected{i}).(keys{j}); 
                            set(handle , 'Parent' , panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , obj.bgColor , 'HorizontalAlignment' , 'left' , ...
                        'FontSize', 12, 'String' , '' , 'Visible' , 'on');
                             subnode.addHandle( 1, 1, handle, 'minsize' , [Inf,20]); 
                             
                            
                            panel.mainnode.addNode(subnode);
                        end
                    end
                    mainnode.addNode(sectionnode);
                    
                    end

                else
                        sectionnode.setWeights(  2 , 1);
                        
                        subnode = LayoutNode( 2 , 1);
                        
                        subnode.addHandle( 1, 1, uicontrol( miscpanel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , obj.bgColor , 'HorizontalAlignment' , 'left' , ...
                    'FontSize', 12, 'String' ,  selected{i} ), 'minsize' , [Inf,20]);
                         handle = obj.handleList.(selected{i});
                         set(handle , 'Parent' , miscpanel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , obj.bgColor , 'HorizontalAlignment' , 'left' , ...
                    'FontSize', 12, 'String' , '', 'Visible' , 'on');    
                        
                        subnode.addHandle(1,1, handle, 'minsize' , [Inf,20]);
                        sectionnode.addNode(subnode);
                        miscpanel.mainnode.addNode(sectionnode);
                        
                end
            end
            printc(mfilename , 'components placed');
            %fixme: memory leak mogelijk
            miscs = length( miscpanel.mainnode.handles);
            misc = LayoutNode(miscs*2 , 1);
            misc.setHandle( miscpanel.handle , 'minsize' ,[0,0]);
            if (miscs > 0), mainnode.addNode( misc  ); end
            
            printc(mfilename, 'prepare layout');
            [w,h] = mainnode.getPrefSize();
            mainnode.setOptions( 'Add' , 1 , 'sliderthreshold' , [200 h] , 'panel' , obj.panelhandle);
            
            mainnode.makeLayoutHappen(  get(obj.panelhandle , 'Position')    );
            obj.mainnode = mainnode;
            printc(mfilename, 'layout done');

        end   
        
        function destructor(obj)
            obj.mainnode.destructor();
            delete(obj);
        end           
    end

    
end




