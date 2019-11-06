classdef ConfigManager
    %CONFIGMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sessiondata;
        configs;
    end
    properties(Constant)
       VALUE  = 1;
       LIST = 2;
       CHECK = 3;
    end
    
    methods
        function obj = ConfigManager(sessiondata)
            obj.sessiondata = sessiondata;
            
            obj.configs.suspend.ID = 'suspend';
            obj.configs.suspend.itemname = 'Pause';
            obj.configs.suspend.title = 'Suspend Computation';
            obj.configs.suspend.subtitle =  'Suspend Computation';
            obj.configs.suspend.type = ConfigManager.LIST;
            obj.configs.suspend.typedata.selection = {'At Special Points' , 'At Each Point', 'Never'};
            
            obj.configs.archive.ID = 'archive';
            obj.configs.archive.itemname = 'Archive';
            obj.configs.archive.title = 'Archive Filter';
            obj.configs.archive.subtitle = 'Maximum number of untitled curves of a particular type:';
            obj.configs.archive.type = ConfigManager.VALUE;
            obj.configs.archive.typedata.validator = @(val) floor(str2num(val)) > 0;
            
            obj.configs.plotoutput.ID = 'plotoutput';
            obj.configs.plotoutput.itemname = 'Output';
            obj.configs.plotoutput.title = 'Plot interval';
            obj.configs.plotoutput.subtitle = 'Plot after X points:';
            obj.configs.plotoutput.type = ConfigManager.VALUE;
            obj.configs.plotoutput.typedata.validator = @(val) floor(str2num(val)) > 0;
        
            
            loadcfg(obj);
        end
        
        function loadcfg(obj)
            if (~ isfield(obj.sessiondata.data , 'config') ||  isempty(obj.sessiondata.data.config))
                obj.sessiondata.data.config.suspend = DefaultValues.OPTIONS.suspend;
                obj.sessiondata.data.config.archive = DefaultValues.OPTIONS.archive;
                obj.sessiondata.data.config.plotoutput = DefaultValues.OPTIONS.plotoutput;
            end
            
        end
        
        function cfglist = getConfigList(obj)
           cfglist = fieldnames(obj.configs);
        end
        
        function cfg = getConfig(obj,id)
           cfg = obj.configs.(id); 
        end
        
        
        
        function setValue(obj , ID , val)
            obj.sessiondata.data.config.(ID) = val;
        end
        
        function v = getValue(obj, ID)
            v = obj.sessiondata.data.config.(ID);
        end
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
end

