classdef ConfigMenu
    %CONFIGMENU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = ConfigMenu(parent, configmanager)
            
            cfglist = configmanager.getConfigList();
            
            for i = 1:length(cfglist)
                cfg = configmanager.getConfig(cfglist{i});
                switch( cfg.type)
                    case ConfigManager.VALUE
                        uimenu(parent , 'Label' , cfg.itemname , 'Callback' , @(o,e) valueCallback(o, configmanager , cfg)); 
                    case ConfigManager.LIST
                        uimenu(parent , 'Label' , cfg.itemname , 'Callback' , @(o,e) listCallback(o, configmanager , cfg)); 
                    case ConfigManager.CHECK
                        warning('CHECK not implemented');
                        
                    otherwise
                        warning([mfilename ' otherwise']);
                end
                
            end
            
        end
        
    end
    
end

function valueCallback(handle , cm , cfg)
    answer = inputdlg( cfg.subtitle ,  cfg.title ,1 ,{ num2str(cm.getValue(cfg.ID)) });
    if (~isempty(answer))
        valid = cfg.typedata.validator(answer{1});
        if (isempty(valid) || ~valid)
           valueCallback(handle, cm , cfg); 
        else
           cm.setValue(cfg.ID , str2num(answer{1})); 
        end
    end

end


function listCallback(handle , cm , cfg)

    [Selection,ok] = listdlg('ListString', cfg.typedata.selection ,'SelectionMode' , 'single' , ...
        'InitialValue' , cm.getValue(cfg.ID)  , 'Name' , cfg.title , 'PromptString' , cfg.subtitle ,'ListSize' , [300 100] );
    
    if (ok)
       cm.setValue(cfg.ID , Selection); 
    end
end
