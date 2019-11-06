classdef CurveManager < handle
    %CURVEMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diagrampath
        curves
        unnamed
        ncurvesgetter;
    end
    
    methods
        function obj = CurveManager(session, diagrampath , previewswitch)

            obj.diagrampath = diagrampath;
            list = CurveManager.getCurveNamesList(diagrampath);

            obj.curves = cell(length(list) , 3);

            if (~isempty(list)), obj.curves(:,1) = list; end %Warning: empty list case causes problems

            
            if ((nargin < 3) || previewswitch)
                for i = 1:size(obj.curves,1)
                    obj.curves{i,3} = obj.createInfostruct(i);
                end
            end
            
            obj.ncurvesgetter = @() session.configmanager.getValue('archive');
        end
        
        
        function [curve , exists] = getCurveByName(obj,name)
            i = obj.findCurveByName(name);
            exists = ~isempty(i);
            if (exists)
                curve = obj.getCurveByIndex(i);
            else
                curve = [];
            end
        end

        function curve = loadCurveFromMemory(obj, name , datastruct)
            i = obj.findCurveByName(name);
            curve = Curve();
            obj.curves{i,2} = curve;
            curve.loadIn(datastruct);
            obj.curves{i,3} = obj.createInfostruct(i);

            %FIXME:
            if (curve.hasFile())
               curve.path =  [obj.diagrampath '/' obj.curves{i,1} '.mat'];
            end
        
        end
        
        
        
        function bool =  curveExist(obj,name)
            bool = ~isempty(obj.findCurveByName(name));
            
        end
        
        function curve  = getCurveByIndex(obj,i)
            if isempty(obj.curves{i,2})
                obj.curves{i,2} = Curve([obj.diagrampath '/' obj.curves{i,1} '.mat']);
                obj.curves{i,2}.label = obj.curves{i,1};
            end
            curve = obj.curves{i,2};
        end
        
        function [s,msg] = renameCurve(obj, name , newname , session)

            if (ismember(newname, obj.curves(:,1)))
               s = 1;
               msg = 'Curvename already exists';
               return;
            else
               index = obj.findCurveByName(name);

               [s,msg] = movefile( [obj.diagrampath '/' name '.mat'] , [obj.diagrampath '/' newname '.mat'] ,'f'); %FILES
               %disp(msg)
               if (s)
                   obj.curves{index,1} = newname;
                   if (~isempty(obj.curves{index,2}))
                       obj.curves{index,2}.label = newname;
                       obj.curves{index,2}.path =  [obj.diagrampath '/' newname ];

                       if ((nargin == 4) && (  session.getCurrentCurve().cmp( obj.curves{index,2} )   ))
                          %disp('RENAMED currentCURVE');
                          session.notify('stateChanged');
                       end
                   end
               end
                               
            end
            
        end
        function deleteCurve(obj, name , session)
            index = obj.findCurveByName(name);
            
	    %DELETE BUGFIX:
            movefile( [obj.diagrampath '/' name '.mat'] , [obj.diagrampath '/dummy'] ,'f'); %FILES
	    delete([obj.diagrampath '/dummy']);  %FILES
            %%%% END BUGFIX


            if (~isempty(obj.curves{index,2}))
                %TODO FIXME  verwijderen handle curve ?
               if ((nargin == 3) && (  session.getCurrentCurve().cmp( obj.curves{index,2} )   )) 
                      %disp('DELETED currentCURVE');
                      obj.unnamed = obj.curves{index,2};
                      obj.unnamed.path = '';
                      obj.unnamed.label = '';
                      session.notify('stateChanged');
                end                    
            end
            obj.curves(index,:) = [];
        end
        
        function list = getCurveList(obj)
            list = obj.curves(:,1);
        end
        
        function b = cmp(obj , cm)
           if (isempty(cm))
               b = false;
           else
              b = strcmp(obj.diagrampath, cm.diagrampath); 
           end
        end
        
        function i = findCurveByName(obj,name)
            i = find(strcmp(obj.curves(:,1), name));
        end
        
        
        function c = getBlankCurve(obj , startpoint)

            if ~isempty(obj.unnamed)
                delete(obj.unnamed);
                obj.unnamed = [];
            end
            
            obj.unnamed = Curve();
            obj.unnamed.label = '';
            c = obj.unnamed;
            
            if (nargin == 2)
               c.startpoint = startpoint;
            else
                c.startpoint = [];
            end
            
        end

	function setUnnamed(obj, curve)
		obj.unnamed = curve;
	end

        function c = getEmptyCurveFrom(obj , curvename)
            
            if ~isempty(obj.unnamed)
                delete(obj.unnamed);
                obj.unnamed = [];
            end            
            
            obj.unnamed = Curve();
            obj.unnamed.label = '';           
            c = obj.unnamed;
            
            parentcurve = obj.getCurveByName(curvename);
            c.copyOverAttributes(parentcurve)
            
        end
        
        
        
        
        function name(obj , startdata, contdata , newIterationN)
            if ~isempty(obj.unnamed)
                ncurves = obj.ncurvesgetter();
                
                
                %compose name::
                if (contdata.getBackwards()), direction = 'b'; else direction = 'f'; end;
                name = [direction  num2str(newIterationN)   '_'        obj.unnamed.getPointType().getLabel() '_' obj.unnamed.getCurveType().getLabel() ];
                
                i = 1;
                
                oldest_i = -1;
                oldest_datenum = Inf;
                
                while ((i<=ncurves)&&(~isempty(obj.findCurveByName([name '(' num2str(i) ')']))))
                    
                    f = dir([obj.diagrampath '/' name '(' num2str(i) ').mat']);
                    if (f.datenum < oldest_datenum)
                        oldest_i = i;
                        oldest_datenum = f.datenum;
                    end
                    i = i + 1;
                end
                
                
                if (i > ncurves)
                    i = oldest_i; %OVERWRITE
                    name = [name '(' num2str(i) ')'];
                else
                    name = [name '(' num2str(i) ')'];
                    obj.addCurve(name , []);
                end
                
                index = obj.findCurveByName(name);
                obj.curves{index,2} = obj.unnamed;
                obj.saveCurve(index);
                
                obj.unnamed = [];
            end
            
        end
        function p = getPath(obj)
            p = obj.diagrampath;
        end
        function setPath(obj, diagrampath)
           obj.diagrampath = diagrampath; 
        end
        
        function addCurve(obj, name , curve)
            len = size(obj.curves,1);
            obj.curves{len+1,1} = name;
            obj.curves{len+1,2} = curve;
            obj.saveCurve(len+1);
        end
        
        function addCurveName(obj , cname)
            len = size(obj.curves,1);
            obj.curves{len+1,1} = cname;
            obj.curves{len+1,2} = [];
            obj.curves{len+1,3} = [];
        end
        
        
        function saveCurve(obj, index)
            path = [obj.diagrampath '/' obj.curves{index,1} '.mat'];
            curve = obj.curves{index,2};
            if (~isempty(curve))
                curve.path = path;
                curve.label = obj.curves{index,1};
                curve.save(path);
                obj.curves{index,3} = obj.createInfostruct(index);
            end
        end
        
        function save(obj, curve , i)
            %FIXME: recalc path
            curve.save( curve.path);
            if (nargin < 3), i = findCurveByName(obj,curve.label); end
            obj.curves{i,3} = obj.createInfostruct(i);
        end
        
        
        function struct = createInfostructByName(obj,name)
            i = obj.findCurveByName(name);
            struct = obj.createInfostruct(i);
        end
        
        function b = comp(obj,cm)
           b = strcmp(obj.diagrampath , cm.diagrampath); 
        end
        
        function struct = createInfostruct(obj,index)
            if ~isempty(obj.curves{index,2})
                curve = obj.curves{index,2};
                s = curve.s;
                point = curve.getPointType().getLabel();
                ctype = curve.getCurveType().getLabel();
            else
                load([obj.diagrampath '/' obj.curves{index,1} '.mat'], 's' , 'ctype' , 'point');
                ctype = deblank(ctype);
                point = deblank(point);
            end
            if (~isempty(s))
                struct.npoints = s(end).index;
                struct.slist = createSlist(s);
            else
                struct.npoints = 0;
                struct.slist = [];
            end
            struct.pointtype = point;
            struct.curvetype = ctype;
            
        end
        function struct = getInfo(obj,index)
            struct = obj.curves{index,3};
        end
        
        function struct = getInfoByName(obj,name)
            i = obj.findCurveByName(name);
            struct = obj.curves{i,3};
        end
	function list = getInfoList(obj)
		list = obj.curves(:,3);
	end
        
	function name = getDiagramName(obj)
		name = choppath(obj.diagrampath);

    end
    
    function nr = getNrOfCurves(obj)
       nr =  size(obj.curves,1);
    end
    
    function s = placeCurve(obj , name , curve)
         
        
    end
    
    
    
    end
    methods(Static)
        function curvelist = getCurveNamesList(path)
            files = dir(path);
            names = {files.name};
            names = names(~[files.isdir]);
            ilist = strfind(names,'.mat');
            curvelist = {};
            for i = 1:length(ilist)
                if (~isempty(ilist{i}) && (ilist{i} == (length(names{i}) - 3)))
                    curvelist{end+1} = names{i}(1:(ilist{i}-1));
                end
            end
        end  
        
        
        
        function [status , message] = moveCurve(session , curvename , fromCM , toCM)
            status = true; message = '';
            newname = curvename;
            
            if (ismember(newname , toCM.curves(:,1)))
                newname = inputdlg('Enter new curvename' , 'curvename already exists' , 1 , {newname});
                if isempty(newname), return; end
                while (ismember(newname , toCm.curves(:,1) ))
                    newname = inputdlg('Enter new curvename' , 'curvename already exists' , 1 , {newname});
                    if isempty(newname), return; end
                end
            end
            %disp(['copyfile:  '  fromCM.getPath() '/' curvename ' ->  ' toCM.getPath() '/' newname]);
            
            [status,message,messageid] = copyfile(   [fromCM.getPath() '/' curvename '.mat'],[toCM.getPath() '/' newname '.mat'] ,'f'); 
            fromCM.deleteCurve( curvename , session);
            toCM.addCurveName(newname);
            
        end
        
        
        
    end
    
    
    
end


function slist = createSlist(s)
    slist = cell(length(s) , 3);
    for i = 1:length(s)
        slist{i,1} = deblank(s(i).label);
        slist{i,2} = s(i).index;
        slist{i,3} = strtrim(s(i).msg);
    end
end



function str = choppath(path)
    if ((path(end) == '\') || (path(end) == '/')), path(end) = ''; end
    str = regexprep(path , '.*[/\\]' , '');
end
