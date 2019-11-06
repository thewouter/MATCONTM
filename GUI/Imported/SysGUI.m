classdef SysGUI
    
   methods(Static)
       
       function new
          
                global system
                warning off;

                system = struct();
                system.path_sys =  [pwd '/Systems/'];
                system.struct = struct();

                systems('init');
                handle = systems();
                uiwait(handle);

                warning on ;         

       end
       function edit(systemname)
       
           if (~isstr(systemname))
              systemname = func2str(systemname); 
           end
           
           warning off;
            global system
            system = struct();
            system.path_sys =  [pwd '/Systems/'];
            load( [system.path_sys  systemname '.mat' ]);
            system.struct = gds;
            handle = systems;
            uiwait(handle);
            warning on;              
           
       end
       
       function userfunctions(systemname)
           if (~ischar(systemname))
              systemname = func2str(systemname); 
           end   
 
           global system
           system = struct();
            system.path_sys =   [pwd '/Systems/'];
            system.struct = struct();
           
           systemmatfile = [system.path_sys  systemname '.mat' ];
           load( systemmatfile );
           system.struct = gds;

           try
               system.struct.uf = [];
               system.struct.uf.UserfunctionsInfo = system.struct.options.UserfunctionsInfo;
               system.struct.uf.Userfunctions = system.struct.options.Userfunctions;
               system.struct.options = [];
           catch ME
               
           end
           
           handle = userfun;
           if (ishandle(handle)) , uiwait(handle); end; %if 'userfun' not closed yet, stall..
           
           system.struct.options = system.struct.uf;
           system.struct.uf = [];
           gds = system.struct; 
           save(systemmatfile , 'gds');          
           
       end
       
   end
    
    
    
    
    
    
end