t = rand(1,10000);
pd1 = makedist('Stable','alpha',1.8,'beta',0,'gam',1,'delta',0);

input = icdf(pd1,t);

fileID = fopen('input.txt','w');
fprintf(fileID,'[ ');
fileID = fopen('input.txt','a+');
fprintf(fileID,'%f, ', input);
fprintf(fileID,' ]');