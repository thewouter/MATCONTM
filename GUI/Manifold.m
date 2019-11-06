classdef Manifold < handle
    
    properties
       points
       arclen
       optM
       man_ds
       
       name = '';
    end
    
    methods
        function obj = Manifold( points , arclen , optM , man_ds)
            obj.points = points;
            obj.arclen = arclen;
            obj.optM = optM;
            obj.man_ds = man_ds;
        end
        
        
        function b = isStable(obj)
           b = strcmp(lower(obj.optM.function), 'smanifold');
        end
        function b = isUnstable(obj)
           b = ~obj.isStable(); 
        end
        
        function s = getName(obj)
            s = obj.name;
        end
        function setName(obj , s)
            obj.name = s; 
        end
        
        function coord = getInitFP(obj)
           coord = obj.man_ds.x0;
        end
        
        function [coord, param] = getInitFixedPoint(obj)
            coord  = obj.man_ds.x0;
            param  = cell2mat(obj.man_ds.P0);
        end
        function save(obj ,filename)
           A = obj.saveobj();
           save(filename , 'A');
        end
        
        function A =  saveobj(obj)
           A.points = obj.points;
           A.arclen = obj.arclen;
           A.optM = obj.optM;
           A.man_ds = obj.man_ds;
           A.name = obj.name; 
        end
        
        
        
        function p =  getAllPoints(obj)
            p = obj.points;
        end
        
        function type = getType(obj)
           type = 'MANIFOLD'; 
        end
        
        function s = toString(obj , varargin)
           stablestr = '';
           if (isempty(varargin))
               stable = obj.isStable();
               if (stable)
                    stablestr = 'stable,';
               else
                    stablestr = 'unstable,';
               end
           end
           s = [obj.name ' (' stablestr  'p=' num2str(size(obj.points , 2)) ',a=' num2str(obj.arclen) ')' ];
        end
    end
    
    methods(Static)
        function mani = load(filename)
            load(filename);
            mani = Manifold( A.points, A.arclen , A.optM , A.man_ds);
            mani.name = A.name;
        end
        
        function mani = loadFromStruct(A)
            mani = Manifold( A.points , A.arclen , A.optM , A.man_ds);
            mani.name = A.name;
        end
        
    end
    
    
    
end
