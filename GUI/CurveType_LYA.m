classdef CurveType_LYA 
    %CURVETYPE_FP Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
    %     L = [ 'NS  ';'PD  '; 'LP  ';'BP  ' ];

    
    function obj = CurveType_O()
    end
    
        function string = getName(obj)
            string = '-';
        end
        function string = getLabel(obj)
            string = 'LYA';
        end
        
        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' ,  'iterationN' , 'FieldsModel' };
            
        end
        function [list,mindim] = getTestfunctions(obj)
            list =    {};
            mindim =  [];
        end
        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters'  };
        end
        
        
        
        function list = getDependantGlobalVars(obj)
           list = {}; 
        end
        
        
        function nr = getReqNrFreeParams(obj)
           nr = 0; 
        end
        
        function col = getDefaultColor(obj)
           col = 'white'; 
        end
        
	function curvedef = getCurveDefinition(obj)
           curvedef = @thisshouldneverbecalled; 
        end
        

        function list = getBranches(obj, pointtag , session)
           if strcmp(pointtag, 'P')
                list = {  Branch_LyaExp( LyaExpAlgo1() , 'LYA1' , 'Compute Lyapunov exponents (QR-method)')};
                
                if length(session.getStartData.getCoordinates) == 2
                    list{end+1} = Branch_LyaExp( LyaExpAlgo2() , 'LYA2' , 'Compute largest Lyapunov exponent (2D-only)');
                end
           else
               list = {};
           end
        end       
        function mat = getSingMatrix(obj)
           mat = [];
        end                
    end
end

