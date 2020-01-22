classdef SelectBranchListbox < handle  
    %SELECTBRANCHMENU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        eventlistener
        strlist;
    end
    
    methods
        function obj = SelectBranchListbox(parent, session , varargin)
            
            branchmanager = session.getBranchManager();
            obj.handle = uicontrol(parent, 'Style' , 'popupmenu' ,   varargin{:});
           
            
           branchmanager.addlistener('newlist' , @(o,e) obj.configure(session,branchmanager));
           branchmanager.addlistener('selectionChanged' , @(o,e) obj.setSelected(branchmanager));
           
           obj.configure(session, branchmanager);
           
           set(obj.handle , 'Callback' , @(o,e) obj.callback(o,session , branchmanager));
        end
        
        
        function configure(obj, session, branchmanager)
            
            list = branchmanager.getList();
           
            len = length(list);
            
            set(obj.handle , 'Enable' , bool2str(len ~= 0));
           
            obj.strlist = cell(1, len);
            for i = 1:len
               obj.strlist{i} = list{i}.toString(); 
            end
            
            if (len == 0)
                set(obj.handle , 'Enable' , 'off' , 'String' , {' '} , 'Value' , 1);
                
            else
                set(obj.handle , 'Enable' , 'on' , 'String' , obj.strlist);
            end
                
            obj.setSelected(branchmanager);
            

        end
        
        function setSelected(obj, branchmanager)
           j =  branchmanager.getSelectionIndex();

           printc(mfilename, 'setSelect:  index=%d' , j);
           if (branchmanager.validSelectionMade())
               set(obj.handle , 'String' , obj.strlist  ,  'Value' , j); 
           else
               printc(mfilename, 'no branch selected -> lockdown');
               set(obj.handle , 'String' , [obj.strlist {'   '}] ,  'Value' ,  length(obj.strlist) + 1);
           end
           
        end
        
        function callback(obj , handle ,session, branchmanager)
            printc(mfilename, 'CALLBACK');
            j =  get(handle, 'Value');
            branchmanager.select(session, j);
            
        end
        
    end
    
end

function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end