classdef ConnectingOrbitCustom
   
    properties 
       C = [];
       name = '';
    end
    
    methods
        function obj = ConnectingOrbitCustom(C, strname)
           obj.C = C;
           obj.name = strname;
        end
        
        function s = toString(obj)
            s = obj.name;
        end
       
        function nr = getNrPoints(obj)
           nr = size(obj.C ,2); 
        end
        
        function points = getAllPoints(obj)
             points = obj.C;
        end
        
        function b = hasBorderPoints(obj)
           b = false; 
        end
        
        function points = getPoints(obj, ~)
           points = obj.C; 
        end
         function type = getType(obj)
            type = 'CONORBIT';
         end       
        
         function A = saveobj(obj)
            A.type = 'custom';
            A.C = obj.C;
            A.name = obj.name;
         end
    end
    methods(Static)
        function conorb = loadFromStruct(A)
            conorb = ConnectingOrbitCustom(A.C , A.name);
        end
        
    end
    
end