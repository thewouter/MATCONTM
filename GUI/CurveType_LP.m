classdef CurveType_LP < handle
    %CURVETYPE_LP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
    end
    
    methods
        function obj = CurveType_LP()
           obj.branches = struct(); 
            
           obj.branches.LP = { Branch('LP','LP', @init_LPm_LPm , 1 , false,'D+bps') };


           obj.branches.CP = { Branch('CP','LP', @init_LPm_LPm , 1 , false,'D+bps') };
           obj.branches.R1 = { Branch('R1','LP', @init_LPm_LPm , 1 , false,'D+bps') };
           obj.branches.LPPD = { Branch('LPPD','LP', @init_LPm_LPm , 1 , false,'D+bps') };
           obj.branches.LPNS = { Branch('LPNS','LP', @init_LPm_LPm , 1 , false,'D+bps') };
 
          
           obj.branches.GPD = { Branch('GPD','LP', @init_GPD_LP2m , 2 , false,'eps+bps') };
           obj.branches.R4 = { Branch('R4','LP', @init_R4_LP4m1 , 4 , true,'eps+bps'),...
                               Branch('R4','LP', @init_R4_LP4m2,  4 , true,'eps+bps')};
           
        end

        function string = getName(obj)
            string = 'Limit Point';
        end
        function string = getLabel(obj)
            string = 'LP';
        end
        
        function col = getDefaultColor(obj)
           col =  DefaultValues.CURVECOLOR.LP; 
        end        
        function [list,mindim] = getTestfunctions(obj)
            list =   {'R1' , 'LPPD' , 'LPNS' , 'CP'};
            mindim = [ 2   ,   2    ,   3    ,  1  ];
        end
        
        function list = getNumericVarList(obj)
            %toevoeging van een testfunctie bij elke branch (CP)
            list = {'coordinates','parameters','testfunctions','multipliers' ,'current_stepsize' , 'user_functions' , 'npoints'};
        end
        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            
             list = {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'multipliers' ,'userfunction' , 'testfunctions' , 'amplitude' };
            
        end
        
        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'lpmds'};
        end
        
        function curvedef = getCurveDefinition(obj)
            curvedef = @limitpointmap;
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
