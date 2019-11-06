classdef InputRestrictions
   properties(Constant)
        INT_g1  = 1;
        INT_g0  = 2;
        INT_ge0 = 3;
        INT     = 4
        POS     = 5;
        POS_0   = 6;
        NUM     = 7;
        CAT     = 8;
        VECTOR  = 9;
        IGNORE  = 10;
        BOOL = 11;
        
        VALIDATOR = { ...
        @(x) isscalar(x) && (floor(x) == x) && (x > 1)       , ... %INT_g1
        @(x) isscalar(x) && (floor(x) == x) && (x > 0)       , ... %INT_g0
        @(x) isscalar(x) && (floor(x) == x) && (x >= 0)      , ... %INT_ge0
        @(x) isscalar(x) && (floor(x) == x)                  , ... %INT
        @(x) isscalar(x) && (x > 0)                          , ... %POS
        @(x) isscalar(x) && (x >= 0)                         , ... %POS_0
        @(x) isscalar(x)                          , ... %NUM 
        @(x) false                            , ... %CAT
        @(x) isvector(x) || isempty(x)        , ... %VECTOR
        @(x) false                            , ... %IGNORE
        @(x) (x == 0) || (x == 1)             }     %BOOL

        ADJUSTER = { ...      
        @(x) floor(x) , ...  %INT_g1
        @(x) floor(x) , ...  %INT_g0
        @(x) floor(x) , ...  %INT_ge0
        @(x) floor(x) , ...  %INT
        @(x) x , ...          %POS
        @(x) x , ...          %POS_0
        @(x) x , ...          %NUM
        @(x) x , ...          %CAT
        @(x) x , ...          %VECTOR
        @(x) 0 , ...          %IGNORE
        @(x) x~=0 }           %BOOL    
    
 
        TOSTRING = { ...      
        @(x) num2str(x , '%.16g'), ...  %INT_g1
        @(x) num2str(x , '%.16g'), ...  %INT_g0
        @(x) num2str(x , '%.16g') , ...  %INT_ge0
        @(x) num2str(x , '%.16g') , ...  %INT
        @(x) num2str(x , '%.16g'), ...          %POS
        @(x) num2str(x , '%.16g') , ...          %POS_0
        @(x) num2str(x , '%.16g') , ...          %NUM
        @(x) x , ...          %CAT
        @(x) EvalVectorBox.vector2string(x) , ...          %VECTOR
        @(x) '' , ...          %IGNORE
        @(x) InputRestrictions.bool2string(x) }           %BOOL          
    
   end

     
    
   
   
   methods(Static)
       
       function b = isNumerical(numcode)
           b = numcode < 8;  %ok for: INT_xx and POS_xx and NUM. not ok for CAT
       end
       function str = bool2string(b)
          if b
              str = 'true';
          else
              str = 'false';
          end
           
       end
   end
 
   
end