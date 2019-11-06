classdef CurveType_HE < handle
    %CURVETYPE_PD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
        
    end
    
    methods
        function obj = CurveType_HE()
           obj.branches = struct(); 
	       obj.branches.CO = { Branch('CO' , 'HE' , @init_Het_Het , 1 , false , 'HCO') };   
           obj.branches.LP_HE = { Branch('LP_HE' , 'HE' , @init_Het_Het , 1 , false , 'HCO') }; 
        end
        
        
        function string = getName(obj)
            string = 'Heteroclinic Connection';
        end
        function string = getLabel(obj)
            string = 'HE';
        end
        function col = getDefaultColor(obj)
           col =  DefaultValues.CURVECOLOR.HE;
        end
        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'hetds'};
        end

        function curvedef = getCurveDefinition(obj)
            curvedef = @heteroclinic;
        end

        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters','testfunctions','current_stepsize' ,  'user_functions' , 'npoints'};
        end            

        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'userfunction' , 'testfunctions' , 'amplitude' };
        end
        
        function [list,mindim] = getTestfunctions(obj)
           list =   {'LP', 'BP'};
           mindim = [ 1   ,  Inf ];
        end  
        
        
        function nr = getReqNrFreeParams(obj)
           nr = 1; 
        end       
        
        
        function list = getBranches(obj, pointtag,session)
           if (isfield(obj.branches,pointtag))
               list = obj.branches.(pointtag);
           else
               list = {};
           end
            
        end   
        function mat = getSingMatrix(obj)
           out = feval(obj.getCurveDefinition());
           mat = feval(out{9});
        end
    end
        
end
