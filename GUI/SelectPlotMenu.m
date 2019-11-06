classdef SelectPlotMenu
    
    properties
        session
        handle
    end
    
    methods
        function obj  = SelectPlotMenu(parent , session, varargin)
            obj.handle = uimenu(parent ,  'Label' , 'Previous Plots' , varargin{:});
            obj.session = session;
            plotmanager = session.plotmanager;
            plotmanager.addlistener('stackChanged' , @(o,e) obj.configure(plotmanager));
            obj.configure(plotmanager);
        end
        
        function configure(obj , plotmanager)
            if ~isempty(obj.handle); delete(allchild(obj.handle)); end;
            
            len = plotmanager.getCfgStackSize();
            if (len == 0)
                set(obj.handle , 'Enable' , 'off');
                
            else
                set(obj.handle , 'Enable' , 'on');
                for i = len:-1:1
                    uimenu(obj.handle , 'Label' , plotmanager.getCfgStr(i) , 'Callback' , @(o,e) plotmanager.selectCfg(obj.session , i));
                    
                    
                end
                
            end
            
        end
        
        
    end
    
    
    
    
    
    
    
end
