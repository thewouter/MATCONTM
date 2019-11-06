classdef manifoldtable
    methods(Static)
        function previewPanel(manifold)
           
            mainnode = LayoutNode(-1,-1,'vertical');
            %mainnode.setOptions('Add' , true);
            f = figure('Visible' , 'off' , 'NumberTitle' , 'off' , 'Name' , manifold.getName());
           
            
            
            [points_h , points_w] = size(manifold.points);
            
            optNames = fieldnames(manifold.optM);
            
            table_points = num2cell(manifold.points);
            
            rownames = cell(1,points_h);
            for i = 1:points_h;
               rownames{i} = ['points(' num2str(i) ',:)' ]; 
            end
            pointstable = uitable(f , 'Data' , table_points , 'RowName' , rownames);
            
            
            infotable = cell(length(optNames) + 10 , 2);
            i = 1;
            
            infotable{i,1} = 'Name';
            infotable{i,2} = manifold.getName();
            i=i+1;
            
            infotable{i,1} = 'Points';
            infotable{i,2} =  points_w;
            i=i+1;
            
            infotable{i,1} = 'ArcLen';
            infotable{i,2} =  manifold.arclen;
            i=i+1;
            
            infotable{i,1} = 'Initial FP';
            infotable{i,2} =  vector2string(manifold.man_ds.x0(:)');
            i=i+1;            
            
            infotable{i,1} = 'Parameters';
            infotable{i,2} =  vector2string(cell2mat(manifold.man_ds.P0)');
            i=i+1;            
            
            infotable{i,1} = 'Eigenvalues';
            infotable{i,2} =  vector2string(manifold.man_ds.eigenvalues');
            i=i+1;                   
            
            infotable{i,1} = 'UEigenvalues';
            infotable{i,2} =  manifold.man_ds.UEigenvalues;
            i=i+1;            
            
            infotable{i,1} = 'SEigenvalues';
            infotable{i,2} =  manifold.man_ds.SEigenvalues;
            i=i+1;              
     
            i=i+1;
     
            infotable{i,1} = '[Options]';
            infotable{i,2} =  ' ';
            i=i+1;    
            
            for j = 1:length(optNames)
               infotable{i,1} = optNames{j};
               infotable{i,2} = manifold.optM.(optNames{j});
                i = i+1;
            end
            tablehandle = uitable(f , 'Units' , 'pixels' ,'RowName' , infotable(:,1) ,  'Data' , infotable(:,2)  , 'ColumnFormat' , {'char' , 'char'});
            tableresizer_opt(tablehandle);
            
            mainnode.addHandle(points_h*2 , 1 , pointstable , 'minsize' ,  [Inf, Inf]); 
            mainnode.addHandle(length(optNames) + 10  ,1, tablehandle , 'minsize' , [Inf,Inf]);
            
            
            [w,h] = mainnode.getTruePrefSize();
            pos = get(f,'Position');
            set(f, 'Position' , [ pos(1), pos(2) , pos(3)  , h * 1.1] );

            mainnode.makeLayoutHappen(get(f,'Position'));
            set(f, 'Visible' , 'on' , 'ResizeFcn' , @(o,e) mainnode.makeLayoutHappen( get(o , 'Position')) , 'DeleteFcn' , @(o,e) delete(mainnode) );
            

        end
        
        
    end
    
end
function tableresizer_opt(handle)
    data = get(handle,'Data');
    col1 = maxChar(data(:,1)) * 9 + 40;
    %col2 = maxChar(data(:,2)) * 9 + 40;
    set(handle , 'ColumnWidth' , {col1});

end
function m = maxChar(cellstr)
l = zeros(1, length(cellstr));
for i = 1:length(cellstr)
   l(i) = length(cellstr{i}); 
end
m = max(l);
end
