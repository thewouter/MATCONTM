function a = powerin(x,y)
% X.^Y for adtayl objects.
% The case where X is a general adtayl object and Y is an integer.
switch y
  case 1, a = x;
  case 2, a = x.*x;
  case 3, a = x.*x.*x;
  case 4, a = x.*x;  a = a.*a; 
  otherwise
    if ~(isnumeric(y) && fix(y)==y)
      error('X^Y for adtayl objects currently requires Y integer')
    end
    xtc = x.tc;
    if y>0
      pow = power0(xtc,y);
    else
      pow = zeros(size(xtc)); pow(1)=1; % vector [1,0,...,0], representing constant 1.
      if y<0
          [m,n,p1]=size(xtc);
          pow1=zeros(1,p1);pow1(1)=1;
          for i=1:m
              for j=1:n
                  xtcij=xtc(i,j,:);
                  xtcij=xtcij(:)';
                
                  ff=filter(1,power00(xtcij,-y), pow1);
             
              pow(i,j,:) = ff(:);
              end
          end
      end
    end
    a = class(struct('tc',pow),'adtayl');
end

%---------------------------
function xtc = power0(xtc,y)
if y~=1
  [m,n,p1]=size(xtc);
  for i=1:m
      for j=1:n
          xtcij=xtc(i,j,:);
          xtcij=xtcij(:)';
          xtc(i,j,:)=power00(xtcij,y);
      end
  end
end

%---------------------------
function pow = power00(xtc,y)
% Assumes xtc is a vector and y>=1.
if y==1
    pow=xtc;
else
    %yover2 = fix(y/2); yrem2 = rem(y,2);
    pyover2 = power00(xtc,fix(y/2));
    pow=filter(pyover2,1, pyover2);
    if rem(y,2)~=0
        pow=filter(xtc,1, pow);
    end
end
