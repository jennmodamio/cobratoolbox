function out=prod(x,dim)

if ~isempty(x)

 precision=x(1).precision;
 % can only handle up to 2 dimensions
 s=size(x);
 if nargin==1
  if any(s==1)
   out=mp(1,precision);
   for ii=1:numel(x)
    out=out*x(ii);
   end
  else
   out=mp(ones(1,s(2)),precision);
   for j=1:s(2)
    for i=1:s(1)
     out(1,j)=out(1,j)*x(i,j);
    end
   end
  end
 elseif nargin==2
  if dim==1
   out=mp(ones(1,s(2)),precision);
   for j=1:s(2)
    for i=1:s(1)
     out(1,j)=out(1,j)*x(i,j);
    end
   end
  elseif dim==2
   out=mp(ones(s(1),1),precision);
   for j=1:s(2)
    for i=1:s(1)
     out(i,1)=out(i,1)*x(i,j);
    end
   end  
  else
   error('mp prod can only handle up to 2-D arrays (11/04)');
  end
 end

else
 out=mp(1);
end