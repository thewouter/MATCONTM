classdef CurveType < handle
    %CURVETYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        curvetypelist = {};
    end
    
    methods
        function obj = CurveType()
           obj.curvetypelist{end+1} = CurveType_FP(); 
           obj.curvetypelist{end+1} = CurveType_LP(); 
           obj.curvetypelist{end+1} = CurveType_PD(); 
           obj.curvetypelist{end+1} = CurveType_NS();
           obj.curvetypelist{end+1} = CurveType_O();
           obj.curvetypelist{end+1} = CurveType_LYA();
           obj.curvetypelist{end+1} = CurveType_HO();
           obj.curvetypelist{end+1} = CurveType_HE();
           obj.curvetypelist{end+1} = CurveType_HomT();
           obj.curvetypelist{end+1} = CurveType_HetT();
        end
        
        function descr = getCurveType(obj,curvelabel)
           for i = 1:length(obj.curvetypelist)
               if ( strcmp(obj.curvetypelist{i}.getLabel(), curvelabel ))
                  descr =  obj.curvetypelist{i};
                  return;
                   
               end
               
           end
           descr = CurveType_X();
        end
        
        function list = getCurvesList(obj)
           list = obj.curvetypelist; 
        end
    end
    methods(Static)
        function descr = getCurveTypeObject(curvelabel)
           if (strcmp(curvelabel,'X'))
               descr = CurveType_X();
           else
               ct = CurveType();
               descr = ct.getCurveType(curvelabel);
           end
        end
        
        function list = getList()
            ct = CurveType();
            list = ct.getCurvesList();
        end
    end
    
end

