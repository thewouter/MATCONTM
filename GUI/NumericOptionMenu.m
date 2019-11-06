classdef NumericOptionMenu
    %NUMERICOPTIONPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
    end
    
    methods
        
        function obj = NumericOptionMenu(parent, numvarlist , varargin)
            
           obj.handle = uimenu(parent, 'Label' , 'Layout' , varargin{:});
           
           optionlist = numvarlist.getSectionList();
           
           for i=1:length(optionlist)
               SwitchMenuItem(obj.handle, optionlist{i} ,  @(x) numvarlist.setSectionEnabled( optionlist{i} , x) ...
	       , @() numvarlist.isSectionEnabled(optionlist{i}) ,  @() numvarlist.isSectionAllowed(optionlist{i}) , numvarlist, 'selectionChanged'); 
           end
       
        end

    end
    
end

