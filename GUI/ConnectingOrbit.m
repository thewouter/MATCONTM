classdef ConnectingOrbit
   
    properties 
       points = [];
       stablemanifold = [];
       unstablemanifold = [];
    end
    
    methods
        function obj = ConnectingOrbit(pointlist, unstable , stable)
           obj.points = pointlist;
           obj.stablemanifold = stable;
           obj.unstablemanifold = unstable;
        end
        
        function s = toString(obj)
            s = [obj.unstablemanifold.getName() ' ^ ' obj.stablemanifold.getName() ',  points=' num2str(size(obj.points,2)) ];
        end
       
        function nr = getNrPoints(obj)
           nr = size(obj.points,2); 
        end
        
        function points = getAllPoints(obj)
             points = [obj.unstablemanifold.getInitFP() , obj.points , obj.stablemanifold.getInitFP()]; 
        end
        function b = hasBorderPoints(obj)
           b = true; 
        end    
        function points = getPoints(obj, format)
            switch(format)
                case 'HO'
                     points = [obj.unstablemanifold.getInitFP() , obj.points];
                case 'HomT'
                    points = [obj.unstablemanifold.getInitFP() , obj.points];
                case 'HetT'
                    points = [obj.unstablemanifold.getInitFP() , obj.points , obj.stablemanifold.getInitFP()];
                case 'HE'
                     points = [obj.unstablemanifold.getInitFP() , obj.points , obj.stablemanifold.getInitFP()]; 
                otherwise
                      points = obj.points;
            end
            
        end        
        function type = getType(obj)
            type = 'CONORBIT';
        end
       
        function A = saveobj(obj)
            A.type = 'computed';
            A.points = obj.points;
            A.stablemanifold = obj.stablemanifold.saveobj();
            A.unstablemanifold = obj.unstablemanifold.saveobj();
        end
        
    end
    
    
    methods(Static)
        function conorb = loadFromStruct(A)
           conorb =  ConnectingOrbit(A.points , ...
               Manifold.loadFromStruct(A.unstablemanifold) , ...
               Manifold.loadFromStruct(A.stablemanifold));
            
        end
        
        function conorb = genericLoadFromStruct(A)
            if (strcmp(A.type , 'custom'))
                conorb = ConnectingOrbitCustom.loadFromStruct(A);
            else
                conorb = ConnectingOrbit.loadFromStruct(A);
            end
        end
        
        
        function homlist = findIntersections( unstable , stable)
            global man_ds;
            man_ds = unstable.man_ds;
            hom = findintersections(unstable.points, stable.points);
            homlen = length(hom);
            homlist = cell(1,homlen);
            for i = 1:homlen
                homlist{i} = ConnectingOrbit(hom{i} , unstable , stable);
            end
            homlist = sortCellByFunc(homlist , @(x) x.getNrPoints() , 'reverse' );
            
        end
        
    end
end