classdef CurveType_NS < handle
    %CURVETYPE_PD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
        
    end
    
    methods
        function obj = CurveType_NS()
           obj.branches = struct(); 
            
           obj.branches.NS = { Branch('NS','NS', @init_NSm_NSm , 1 , false,'D') };
          

           obj.branches.CH = { Branch('CH','NS', @init_NSm_NSm , 1 , false,'D') };
           obj.branches.R1 = { Branch('R1','NS', @init_NSm_NSm , 1 , false,'D') };
           obj.branches.R2 = { Branch('R2','NS', @init_NSm_NSm , 1 , false,'D') ,...
                               Branch('R2','NS' ,@init_R2_NS2m , 2 , true ,'eps')};
           obj.branches.R3 = { Branch('R3','NS', @init_NSm_NSm , 1 , false,'D') ,...
                               Branch('R3','NS', @init_R3_NS3m , 3 , false,'eps+bps')};
           obj.branches.R4 = { Branch('R4','NS', @init_NSm_NSm , 1 , false,'D') ,...
                               Branch('R4','NS', @init_R4_NS4m , 4 , true,'eps+bps')};
                           
           obj.branches.LPPD ={Branch('LPPD','NS',@init_LPPD_NS2m,2, true,'eps') };
           
           obj.branches.LPNS = { Branch('LPNS','NS', @init_NSm_NSm , 1 , false,'D') };
           
           obj.branches.PDNS = { Branch('PDNS','NS',  @init_NSm_NSm , 1 , false,'D'),...
                                 Branch('PDNS','NS',@init_PDNS_NS2m , 2, false,'eps') };
                             
           obj.branches.NSNS = { Branch('NSNS','NS', @init_NSm_NSm_Same , 1 , false,'DS') ,...
                                 Branch('NSNS','NS', @init_NSm_NSm_Other , 1 , false,'DS') }; 
           
        end
        
        
        function string = getName(obj)
            string = 'Neimark-Sacker';
        end
        function string = getLabel(obj)
            string = 'NS';
        end
        function col = getDefaultColor(obj)
           col =  DefaultValues.CURVECOLOR.NS;
        end
        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'nsmds'};
        end

        function curvedef = getCurveDefinition(obj)
            curvedef = @neimarksackermap;
        end

        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters','testfunctions','multipliers' ,'current_stepsize' ,  'user_functions' , 'npoints'};
        end            
        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'multipliers' ,'userfunction' , 'testfunctions' , 'amplitude' };
        end
        
        function [list,mindim] = getTestfunctions(obj)
           list =   {'CH', 'PDNS', 'LPNS', 'R1', 'NSNS', 'R2', 'R3', 'R4'};
           mindim = [ 2   ,  3   ,   3   ,  2  ,   4   ,   2  ,  2  , 2  ];
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
