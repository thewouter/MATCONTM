classdef SystemSpace < handle
    %SYSTEMSPACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        struct
        
        path_sys = '';
        options;
        old_struct

    end
    
    methods
        function obj = SystemSpace(session)
            obj.options = session.optioninterface;
            obj.path_sys = session.getSystemsPath();
        end
    end
    
    methods(Static)
        
        function sys = loadNewSystem(session)
            global system
            
            
            warning off
            p = pwd();
            system = SystemSpace(session);
            systems('init');
            handle = systems();
            uiwait(handle);
            sys = SystemSpace.convertToSystem();
            
            system = [];
            cd(p);
            warning on
        end
        
        function sys = loadSystem(session,name)
            global system
            warning off
           
            system = SystemSpace(session);
            load(name);
            system.struct = gds;
            sys = SystemSpace.convertToSystem();
            warning on
        end
        
        function newsys = editSystem(session , sys)
            warning off
            p = pwd();
            global system
            system = SystemSpace(session);
            
            load(sys.getPath());
            system.struct = gds;
            
            handle = systems;
            uiwait(handle);
            
            newsys = SystemSpace.convertToSystem();
            
            cd(p);
            warning on
        end
        
        
        function userfunctionsEdit(session , sys)
            
           warning off; 
           p = pwd();
           global system
           system = SystemSpace(session);
           printc(mfilename ,  sys.getPath());
           load(sys.getPath());
           system.struct = gds;

           try
               system.struct.uf = [];
               system.struct.uf.UserfunctionsInfo = system.struct.options.UserfunctionsInfo;
               system.struct.uf.Userfunctions = system.struct.options.Userfunctions;
               system.struct.options = [];
           catch ME
               printc('userfunctionsEdit' , ME.message);
           end
           
           handle = userfun;
           if (ishandle(handle)) , uiwait(handle); end; %if 'userfun' not closed yet, stall..
           printc('userfunctionsEdit' , 'userfun DONE\n');
           system.struct.options = system.struct.uf;
           system.struct.uf = [];
           gds = system.struct;
           save(sys.getPath() , 'gds');
           if (isfield(system.struct, 'userfunction') && isfield(system.struct.options , 'UserfunctionsInfo'))
              sys.setUserfunctions( system.struct.userfunction   , system.struct.options.UserfunctionsInfo)
              %%%:
              session.notify('newSystem');
           end
            cd(p);
           warning on;
        end
        
        
        function sys = convertToSystem()
            global system
            
            if (isempty(system.struct.system))
                sys = [];
                return;
            else
                clen = size(system.struct.coordinates ,1);
                plen = size(system.struct.parameters,1);
                coords = cell(1,clen);
                params = cell(1,plen);
                for i = 1:clen
                    coords{i} =  system.struct.coordinates{i,1};
                end
                for i = 1:plen
                    params{i} =  system.struct.parameters{i,1};
                end
                location = strcat(system.path_sys, system.struct.system);
                
                
                sys = System( str2func(system.struct.system), coords, params,... 
                        system.struct.system, location, system.struct.der, system.struct.equations);
                
                 if (isfield(system.struct, 'userfunction') && isfield(system.struct.options , 'UserfunctionsInfo'))
                    sys.setUserfunctions( system.struct.userfunction   , system.struct.options.UserfunctionsInfo)
                 end
            end
        end
        function list = getEnabledUserFunctions(enabled , uf)
           list = {};
           if (~enabled) , return;  end;
            
           for i = 1:length(uf)
              if(uf(i).state)
                list{end+1} = [uf(i).name '_' uf(i).label];
              end
           end
        end
        
        function uf = setEnabledUserFunctions( list , uf)
            for i = 1:length(uf)
                if (ismember([uf(i).name '_' uf(i).label] , list) && uf(i).valid)
                        uf(i).state = 1;
                end
            end
        end
        
        
        
    end
    
end

