classdef CurveType_O 
    %CURVETYPE_FP Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
    %     L = [ 'NS  ';'PD  '; 'LP  ';'BP  ' ];

    
    function obj = CurveType_O()
    end
    
        function string = getName(obj)
            string = 'Orbit';
        end
        function string = getLabel(obj)
            string = 'O';
        end
        
        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' ,  'iterationN'  , 'orbitpoints' };
            
        end
        function [list,mindim] = getTestfunctions(obj)
            list =    {};
            mindim =  [];
        end
        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters'  };
        end
        
        
        
        function list = getDependantGlobalVars(obj)
           list = {'cds' , 'ods'}; 
        end
        
        
        function nr = getReqNrFreeParams(obj)
           nr = 0; 
        end
        
        function col = getDefaultColor(obj)
           col = 'black'; 
        end
        
	function curvedef = getCurveDefinition(obj)
           curvedef = @fixedpointmap; 
        end
        

        function list = getBranches(obj, pointtag,session)
           if strcmp(pointtag, 'P')
                list = { Branch_O()};
           else
               list = {};
           end
        end       
        function mat = getSingMatrix(obj)
           mat = [];
        end                
    end
end

