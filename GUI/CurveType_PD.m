classdef CurveType_PD < handle
    %CURVETYPE_PD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
    end
    %   L = [ 'R2  '; 'LPPD'; 'PDNS'; 'GPD '];

    methods
        function obj = CurveType_PD()
            obj.branches = struct();
            
            obj.branches.PD = { Branch('PD','PD', @init_PDm_PDm , 1 , false , 'D+bps') };

            obj.branches.GPD = { Branch('GPD','PD', @init_PDm_PDm , 1 , false,'D+bps') };
            obj.branches.R2 = { Branch('R2','PD', @init_PDm_PDm , 1 , false,'D+bps') };
            obj.branches.LPPD = { Branch('LPPD','PD', @init_PDm_PDm , 1 , false,'D+bps') };
            obj.branches.PDNS = { Branch('PDNS','PD', @init_PDm_PDm , 1 , false,'D+bps') };
            
            
        end
        
        function col = getDefaultColor(obj)
           col = DefaultValues.CURVECOLOR.PD; 
        end        
        
        function string = getName(obj)
            string = 'Period Doubling';
        end
        function string = getLabel(obj)
            string = 'PD';
        end

        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'pdmds'};
        end

        function curvedef = getCurveDefinition(obj)
            curvedef = @perioddoublingmap;
        end

        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters','testfunctions','multipliers' ,'current_stepsize' , 'user_functions' , 'npoints'};
        end            
        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'multipliers' ,'userfunction' , 'testfunctions' , 'amplitude' };
        end
        function [list , mindim] = getTestfunctions(obj)
           list =   {'R2' , 'LPPD' , 'PDNS' , 'GPD'}; 
           mindim = [  2 ,     2 ,       3 ,     1 ];
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
