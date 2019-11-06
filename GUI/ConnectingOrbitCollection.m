classdef ConnectingOrbitCollection < handle
    
    properties
       customList = {};
       computedList = {};
       
       customLen = 0;
       computedLen = 0;
    end
    
   methods
       function obj = ConnectingOrbitCollection(listcomputed)
           obj.computedList = listcomputed;
           obj.computeLen();
       end
       
       
       function computeLen(obj)
          obj.customLen = length(obj.customList);
          obj.computedLen = length(obj.computedList);
       end
       
       function index = addOrbit(obj , conorb)
          obj.customList = [ obj.customList  , {conorb} ]; 
          obj.computeLen();
          index = obj.customLen;
       end
       
       function delOrbit(obj , index)
          if (index <= obj.customLen)
              obj.customList(index) = [];
          else
             index = index - obj.customLen;
             obj.computedList(index) = [];
              
          end
          
          obj.computeLen();
       end
       
       function l = getLength(obj)
           l = obj.customLen + obj.computedLen;
       end
       
       function c = get(obj, index)
          if (index <= obj.customLen)
              c = obj.customList{index};
          else
             index = index - obj.customLen;
             c = obj.computedList{index};
          end
           
       end
       
       function setComputedList(obj , computed)
          obj.computedList = computed;
          obj.computeLen();
       end
       
   end
    
    
    
    
    
    
    
    
    
    
end