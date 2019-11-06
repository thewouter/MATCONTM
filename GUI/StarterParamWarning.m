classdef StarterParamWarning < handle
    %STARTERPARAMWARNING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        startmodel
        
        listener1
        listener2
    end
    
    methods
        function obj = StarterParamWarning(parent, startmodel , varargin)
            obj.handle = uicontrol(parent , 'Style' , 'text' , 'String' , '  ' , varargin{:} ,'DeleteFcn' , @(o,e) obj.destructor());
            
            obj.listener1 = startmodel.addlistener('structureChanged' , @(o,e) obj.resetMessage());
            obj.listener2 = startmodel.addlistener('freeParamChanged' , @(o,e) obj.resetMessage());
            obj.startmodel = startmodel;
            obj.resetMessage();
        end
        
        
        function resetMessage(obj)    
            curvetype = obj.startmodel.getCurrentCurveType();
            paramReq = curvetype.getReqNrFreeParams();
            paramSet = obj.startmodel.getNrFreeParams();
            
            
            if (paramReq == paramSet) || (paramReq == 0)
                 set(obj.handle , 'String' , ' ');
            else
                 if (paramReq == 1), s = ' is'; else s = 's are'; end
                 
                 set(obj.handle , 'ForegroundColor' , 'red' , 'String' ,  [ numToString(paramReq) ' active parameter' s  ' needed for a ' curvetype.getName() ' continuation']);
            end
        end
        
        function destructor(obj)
           delete(obj.listener1);
           delete(obj.listener2);
           delete(obj);
        end
        
    end
    
end

function str = numToString(i)
    switch(i)
        case 0
            str = 'Zero';
        case 1
            str = 'One';
        case 2
            str = 'Two';
        otherwise
            str = num2str(i);     
    end
end