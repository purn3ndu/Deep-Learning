function[r,c]=autocross(x,o,lg)

N = length(x);
for m = 1:lg
    for n = 1 : N+1 -lg
        xs(m,n) = x(n-1+m);
    end;
end;

r1 = xs*xs';
r = r1'./(N-lg+1);
size(xs);
size(o);
otrunc = o(lg:size(o,2));
size(xs);
size(o);
size(otrunc);
c1 = xs*otrunc';
c = c1'./(N-lg+1);