classdef CurveType_HomT < handle
    %CURVETYPE_PD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
        
    end
    
    methods
        function obj = CurveType_HomT()
           obj.branches = struct(); 
	   obj.branches.LP_HO = { Branch('LP_HO' , 'HomT' , @init_HomT_HomT , 1 , false , 'HCT') };   
           
        end
        
        
        function string = getName(obj)
            string = 'Homoclinic Tangency';
        end
        function string = getLabel(obj)
            string = 'HomT';
        end
        function col = getDefaultColor(obj)
           col =  DefaultValues.CURVECOLOR.HomT;
        end
        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'homTds' , 'homds'};
        end

        function curvedef = getCurveDefinition(obj)
            curvedef = @homoclinicT;
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
