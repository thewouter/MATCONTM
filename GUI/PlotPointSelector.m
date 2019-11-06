classdef PlotPointSelector
    %PLOTPOINTSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    

    properties
        session
        curvemanager
    end
    
    methods
        function obj = PlotPointSelector(session)
            obj.session = session;
            obj.curvemanager = session.getCurveManager();
        end
        
        
        

        
        function selectPointByIndex(obj, pointhandle, curve, x_index)
            
            for i = 2:(length(curve.s)-1)
                if (curve.s(i).index == x_index);
                    obj.selectPoint(pointhandle, curve, i);
                    return;
                end
                
            end
            
            printc(mfilename ,[' point at ' num2str(x_index) ' is not that special \n' ]);
            
        end


        function selectPoint(obj, pointhandle,  curve, s_index)
            t_old = get(pointhandle,'UserData');
            
            
            if (etime(clock , t_old) < 0.5)
                %check named, check in diagram , check session unlocked
                if(obj.session.isUnlocked())
                    if (curve.hasFile())
                        if (obj.curvemanager.findCurveByName(curve.getLabel()))


                            pt = deblank(curve.s(s_index).label);

                            if (strcmp('Yes' ,  questdlg(['Load in ' pt ' (' curve.s(s_index).msg ') from "'  obj.curvemanager.getDiagramName() '/' curve.getLabel() '"'], ['Load ' pt ' point'] )))
                                Curve.loadInPoint(obj.session , obj.session.system , obj.curvemanager  , curve , s_index);
                            end

                        else
                            printc(mfilename ,': curve has moved to another diagram or deleted\n');
                        end

                    else
                        printc(mfilename ,': curve not yet computed ? unsure\n');
                    end
                else
                    printc(mfilename ,': Computing seems to be in progress: not allowed\n');
                end   
            else
                set(pointhandle,'UserData' , clock);
            end
        end
        
        
    end
    
end

