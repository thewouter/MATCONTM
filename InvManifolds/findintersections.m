function [HomCell]=findintersections(Uman,Sman)
% VERY IMPORTANT: FIRST THE UNSTABLE MANIFOLD, THEN THE STABLE ONE!
intersections=[];

global opt_man
global man_ds

a=Uman;
b=Sman;

tic
for j=1:(length(b)-1)
    x1=b(1,j);
    x2=b(1,j+1);
    y1=b(2,j);
    y2=b(2,j+1);
    
    fold=(x2-x1)*(a(2,1)-y2)-(y2-y1)*(a(1,1)-x2);
    finded=[];
    for i=2:length(a)
        fnew=(x2-x1)*(a(2,i)-y2)-(y2-y1)*(a(1,i)-x2);
        if (fnew*fold)<0
            system=[1,                  0,                  x2-x1; ...
                    0,                  1,                  y2-y1; ...
                    a(2,i)-a(2,i-1),    a(1,i-1)-a(1,i),       0    ];
            RHS=[x2;y2;a(2,i)*a(1,i-1)-a(1,i)*a(2,i-1)];
            int=system\RHS;
            if int(3)>=0 && int(3)<=1
                finded=[int,finded];
            end
        end
        fold=fnew;
    end
    if ~isempty(finded)
        [dummy,ordine]= sort(finded(3,:));
        intersections=[finded(1:2,ordine),intersections];
    end
end
toc


homCurves=zeros(1+size(intersections,1),size(intersections,2));
homCurves(2:end,:)=intersections;
%%
index=1;
findedind=1;
while ~isempty(findedind)
    homCurves(1,findedind)=index;
    j=findedind;
    f_p=feval(man_ds.func,0,homCurves(2:end,j),man_ds.P0{:});
    for i=j+1:size(homCurves,2)
        if norm(homCurves(2:end,i)-f_p)<1e-3
            homCurves(1,i)=index;
            f_p=feval(man_ds.func,0,homCurves(2:end,i),man_ds.P0{:});
        end      
    end
    index=index+1;
    findedind=find(homCurves(1,:)==0,1);
end
assignin('base','homCurves',homCurves);

index=index-1;
HomCell=cell(index,1);
for i=1:index
    indici=homCurves(1,:)==i;
    HomCell{i}=homCurves(2:end,indici);
end
toc
%%
end
