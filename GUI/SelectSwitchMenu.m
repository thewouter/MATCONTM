classdef SelectSwitchMenu
    %SELECTSWITCHMENU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
    end
    
    methods
        
        function obj = SelectSwitchMenu(parent , sessiondata , menuname , switchTAG , varargin)
            obj.handle = uimenu(parent ,'Label'  , menuname , varargin{:});
            
            sw = fieldnames(sessiondata.data.opt);
            
            for i = 1:length(sw)
                if strcmp(sessiondata.getSwitchTag(sw{i}), switchTAG)
                    uimenu(obj.handle , 'Label' , sessiondata.getSwitchName(sw{i}) , 'Checked' , bool2str(sessiondata.getSwitch(sw{i})) , 'Callback' , @(o,e) callback(o, sessiondata , sw{i})  );
                end
            end
        end
    end
    
end

function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end


function callback(handle , sessiondata, label)
    val = ~ strcmp(get(handle , 'Checked'),'on');
    sessiondata.setSwitch(label, val);
    set(handle , 'Checked' , bool2str(val));
end