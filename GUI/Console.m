classdef Console

    %CONSOLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        outputhandle
        idlist
        stamp
    end
    
    methods
        
        function obj = Console(session)
            
             obj.stamp = clock;
             
             if (nargin == 1)
                f = session.getWindowManager().demandWindow('console'); 
             else
                f = figure('Position' , [10 10 560 420] );
             end
             
             node = LayoutNode(-1,-1);
             
             obj.idlist = uicontrol(f ,'Style' , 'listbox', 'HorizontalAlignment' , 'left' , 'Enable' , 'inactive' , 'BackgroundColor' , 'white'...
                 , 'String' , {'Console:' , ''} , 'Position' , [10 10 120 400]);
             obj.outputhandle = uicontrol(f ,'Style' , 'listbox', 'HorizontalAlignment' , 'left' , 'Enable' , 'inactive' , 'BackgroundColor' , 'white'...
                 , 'String' ,  {'' , ''}  , 'Position' , [140 10 400 400]);
             
             node.addHandle(1,1,  obj.idlist , 'minsize' , [Inf,Inf]  );
             node.addHandle(3,3 , obj.outputhandle , 'minsize' , [Inf,Inf]  );
             
             
             install(obj);
             
             uimenu( f , 'Label' , 'clear' , 'Callback' , @(o,e) obj.clearconsole());
             
             node.makeLayoutHappen( get(f, 'Position'));
             set([obj.idlist obj.outputhandle] , 'Units' , 'normalized' , 'DeleteFcn' , @(o,e) shutdown(obj));
             set(f,'Visible' , 'on');
        end

        function print(obj, id , varargin)
        global console_ignore
            if (ismember(id , console_ignore))
                return;
            end
            s =  sprintf(varargin{:});
            
            
            ss = get(obj.outputhandle , 'String');
            ids = get(obj.idlist , 'String');
            
            set( obj.outputhandle , 'String' ,   [ss ; s] , 'ListboxTop' , length(ss) );
            set(obj.idlist , 'String' , [ids; id] , 'ListboxTop' , length(ids));
        end
        
        function clearconsole(obj)
           set([obj.outputhandle obj.idlist] , 'String' , {});
        end

        
        function shutdown(obj)
        global console  console_ignore
            console = [];
            console_ignore = {'nothing'};
        end
        function install(obj)
        global console;
            console = obj;
        end
    end
    
    
    methods(Static)
        
        function monitorEvents(object , recursive)
            
            ev = events(object);
            
            for i = 1:length(ev)
                object.addlistener( ev{i} , @(o,e) reportEvent(e));
                printc( mfilename , [class(object) ': registering ' ev{i} ]);
            end
            
            if (nargin == 2)
                prop = properties(object);
                
                for i = 1:length(prop)
                    evnum = length(events(   object.(prop{i}) ));
                    if (evnum > 1)
                        Console.monitorEvents(  object.(prop{i}) );
                    end
                end
            end
            
        end
        
    end
end


function reportEvent(e)
    printc(class(e.Source) , e.EventName);
end
