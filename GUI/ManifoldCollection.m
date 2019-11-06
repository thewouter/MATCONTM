classdef ManifoldCollection < handle
    
    
    properties
       manlist = {}; 
       
       numberadded = [ 0 0 ];
    end
    events
       settingChanged 
    end
    
    methods
        function obj = ManifoldCollection()
           obj.manlist = {}; 
        end
        
        function len = getNrManifolds(obj)
           len = length(obj.manlist); 
        end
        
        
        function c = countManifolds(obj , stable)
            c = 0;
            for i = 1:length(obj.manlist)
                c = c + (stable == obj.manlist(i).manifold.isStable());
            end
            
        end
        
        function deleteManifold(obj , nr)
            obj.manlist(nr) = [];
            obj.notify('settingChanged');
        end
        
        function delManifoldByIndex(obj,  index)
           obj.manlist(index) = []; 
           obj.notify('settingChanged');
        end
        
        
        function name = addManifold(obj , manifold , name)
            
            if isempty(name)
                if (manifold.isStable())
                    obj.numberadded(1) = obj.numberadded(1) + 1;
                    name  = ['StableManifold_' num2str(obj.numberadded(1))];
                else
                    obj.numberadded(2) = obj.numberadded(2) + 1;
                    name = ['UnstableManifold_' num2str(obj.numberadded(2))];
                    
                end
            end
            manifold.name = name;
            manstruct  = struct('name' , name  , 'manifold' , manifold);
            obj.manlist = [ manstruct  ,  obj.manlist ];
            
            obj.notify('settingChanged');
            
        end
        function  mani = getByIndex(obj , index)
            mani = obj.manlist(index).manifold;
            
        end
        function list = getManifoldList(obj)
            if (isempty(obj.manlist))
                list = {};
            else
                list = { obj.manlist.name };
            end
        end
        
        function b = isNameTaken(obj , name)
            b = sum(ismember(obj.getManifoldList() , name));
        end
        
    end
    
    
    
    
    
    
    
    
end