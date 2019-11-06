classdef CurveType_HetT < handle
    %CURVETYPE_PD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
        
    end
    
    methods
        function obj = CurveType_HetT()
           obj.branches = struct(); 
	   obj.branches.LP_HE = { Branch('LP_HE' , 'HetT' , @init_HetT_HetT , 1 , false , 'HCT') };   
        end
        
        
        function string = getName(obj)
            string = 'Heteroclinic Tangency';
        end
        function string = getLabel(obj)
            string = 'HetT';
        end
        function col = getDefaultColor(obj)
           col =  DefaultValues.CURVECOLOR.HetT;
        end
        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'hetTds' , 'hetds'};
        end

        function curvedef = getCurveDefinition(obj)
            curvedef = @heteroclinicT;
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
           mindim = [ Inf   ,  Inf ];
        end  
        
        
        function nr = getReqNrFreeParams(obj)
           nr = 2; 
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
