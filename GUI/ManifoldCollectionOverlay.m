classdef ManifoldCollectionOverlay < handle
    
    
    properties
        manifoldcollection;
        mtype;
        map = [];
        eventlistener;
    end
    
    properties(Constant)
        STABLE = true;
        UNSTABLE = false;
    end

    
    methods
        function obj = ManifoldCollectionOverlay(mc ,mtype )
            obj.manifoldcollection = mc;
            obj.mtype = mtype;
            obj.buildMap();
        end
        
        function len = getNrManifolds(obj)
             len = length(obj.map);
        end
        
        function buildMap(obj)
           len = obj.manifoldcollection.getNrManifolds(); 
            
           map = [];
           for i = 1:len
              type = obj.manifoldcollection.getByIndex(i).isStable();
              if (~ obj.mtype)
                    type = ~type;
              end
              if (type)
                 map =  [map , i];
              end
           end
           obj.map = map;
            
        end
        
        
        function deleteManifold(obj , nr)
            obj.manifoldcollection.deleteManifold( obj.map(nr) );
            obj.buildMap();
        end
        
        function delManifoldByIndex(obj,  nr)
            obj.manifoldcollection.deleteManifold( obj.map(nr) );
            obj.buildMap();           
        end
        
        
        function name = addManifold(obj , manifold , name)
            name = obj.manifoldcollection.addManifold(manifold , name);
            obj.buildMap();
            
        end
        function  mani = getByIndex(obj , index)
            mani = obj.manifoldcollection.getByIndex(obj.map(index));
            
        end
        function list = getManifoldList(obj)
            
            if (isempty(obj.map))
                list = {};
            else
                list = { obj.manifoldcollection.manlist(obj.map).name };
            end
        end

    end
    
    
    
    
    
    
    
    
end
