 classdef tablepreviews
    methods(Static)
        function previewPanel(c)
            f = figure('Visible' , 'off' , 'NumberTitle' , 'off' , 'Name' , c.getLabel());
            mainnode = LayoutNode(-1,-1,'vertical');
            mainnode.setOptions('Add' , true);
            
            h1 = tablepreviews.makeTable(f, c.x , c.v , c.h , c.f );
            h2 = tablepreviews.makeTable_s(f, c.s );
            
            s_tableresizer(h2);
            mainnode.addHandle(10 , 1 , h1, 'minsize' , [Inf, 0]);
            mainnode.addHandle(3 , 1 , h2 , 'minsize' , [Inf, 0] );
            
            h3 = uitable( f );
            mainnode.addHandle(3 , 1 , h3 , 'minsize' , [Inf, 100]); 
            
            set(h2 , 'CellSelectionCallback' , @(o,e) tablepreviews.updateSdata(o,e,h3 , c.s) );
            
            mainnode.makeLayoutHappen( get(f,'Position'));
            set(f,'Visible' , 'on' , 'ResizeFcn' , @(o,e)  mainnode.makeLayoutHappen( get(o,'Position')) , 'DeleteFcn' , @(o,e) delete(mainnode));
        end
        
        function updateSdata(o,e,tablehandle , s_struct)
            tablepreviews.fill_Sdata(tablehandle, s_struct( e.Indices(1)).data);
        end
        
        function handle = makeTable_s(parent,s,varargin)
            len = length(s);
            table = cell(len,2);
            for i = 1:len
                table{i,1} = s(i).label;
                table{i,2} = num2str(s(i).index);
                table{i,3} = s(i).msg;
            end
            handle = uitable(parent, 'Data' , table , 'RowName', [], 'ColumnName' , {'Label' , 'Index' , 'Message'}, varargin{:});
        end
        
        function handle = makeTable(parent, x,v,h,f,varargin)
            len = size(x,2);
            n = ones(1,len);
            blankline = mat2cell(blanks(len),1,n);
            
            m_x = size(x,1);
            table_x = mat2cell(x,ones(1,m_x) , n);
            
	    if(~isempty(v))
	    	m_v = size(v,1);
            	table_v = mat2cell(v,ones(1,m_v) , n);
            else
		m_v = 0;
		table_v = [];
	    end

	    if(~isempty(h))
		    m_h = size(h,1);
		    table_h = mat2cell(h,ones(1,m_h) , n);
            else
		    m_h = 0;
		    table_h = [];
	    end

	    if (~isempty(f))
		    m_f = size(f,1);
		    table_f = mat2cell(f,ones(1,m_f) , n);
        else
            m_f = 0;
            table_f = [];
	    end

            rownames = {};
            for i=1:m_x
                rownames{end+1} = ['x(' num2str(i) ',:)'];
            end
            rownames{end+1}  = '';
            for i=1:m_v
                rownames{end+1} = ['v(' num2str(i) ',:)'];
            end
            rownames{end+1}  = '';
            for i=1:m_h
                rownames{end+1} = ['h(' num2str(i) ',:)'];
            end
            rownames{end+1}  = '';
            for i=1:m_f
                rownames{end+1} = ['f(' num2str(i) ',:)'];
            end
           
            table = [table_x;blankline;table_v;blankline;table_h;blankline;table_f];
            handle = uitable(parent, 'Data' , table , 'RowName', rownames , varargin{:});
        end
        
        function fill_Sdata(tablehandle, sd)
           
            table = cell(0,0);
            rownames = cell(0,0);
            
            %FIXME: sd niet noodzakelijk altijd een struct , check
            
	    if (isstruct(sd))
	    fields = fieldnames(sd);
            
            
            row = 1;
            for k = 1:length(fields)
                rownames{row} = fields{k};
                val = sd.(fields{k});
                if (isempty( val))
                   table{row,1} = '[]';
                   row = row + 1;                    
                    
                    
                elseif (isnumeric( val ) )
                    [x,y] = size(val);
                    for i=1:x
                       for j = 1:y 
                         table{row + i - 1,j} = val(i,j);
                       end
                    end
                    row = row + x;
                    
                    
                else
                   table{row,1} = '???';
                   row = row + 1;
                end
            end
            
            
		    set(tablehandle, 'Data' , table , 'RowName', rownames  , 'ColumnName' , []);
            else
		    set(tablehandle, 'Data' , [] , 'RowName', []  , 'ColumnName' , []);
	    end
        end
        
        
        
        
        function test(s , i)
           openvar s(i).data; 
        end
    end
end

function s_tableresizer(handle)
    data = get(handle,'Data');
    col1 = maxChar(data(:,1)) * 7 + 40;
    col2 = maxChar(data(:,2)) * 7 + 40;
    col3 = maxChar(data(:,3)) * 7;
    
    set(handle , 'ColumnWidth' , {col1,col2,col3});


end
function m = maxChar(cellstr)
l = zeros(1, length(cellstr));
for i = 1:length(cellstr)
   l(i) = length(cellstr{i}); 
end
m = max(l);
end
