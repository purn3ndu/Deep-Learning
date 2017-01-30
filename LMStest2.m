
inp = input10k();

fileID = fopen('test.txt','w');
fprintf(fileID,'File start\n\n');


b = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1];
a = [1, -1];
sysout = filter(b, a, inp);

%figure
%plot(sysout);

whiteNoise = wgn(1, 10000, 0.1);
%plot(whiteNoise);
d = sysout + whiteNoise;
%figure
%plot(dn);

totallength=size(d,1);
%for filterorder = [5,7,9, 10, 15, 30]


%Take 60 points for training
N=length(inp) ;	
%begin of algorithm
mu = 0.01;
filterorderbag = [5,7,8, 10, 15,18, 20,25, 30,45];
NMSEmatrix = zeros(length(filterorderbag),1);
for filterindex = 1:length(filterorderbag)
    filterorder = filterorderbag(filterindex);
    y = zeros ( N  , 1 ) ;
    sysorder = filterorder;
    w = zeros ( sysorder  , 1 ) ;
    
    Esqsum = 0;
    
    for n = sysorder : N 
        u = inp(n:-1:n-sysorder+1) ;
        yval= u * w;
        y(n)= yval;
        e(n) = d(n) - y(n) ;

        w = w + (mu * u * e(n))' ;

        Esqsum = Esqsum + e(n)*e(n);

    end 

    NMSE = Esqsum/(inp*inp');
    %disp(NMSE);
    NMSEmatrix(filterindex,1) = NMSE;
    
    %{
    hold on
    plot(d,'r')
    plot(y,'b');
    title('System output');
    xlabel('Samples')
    ylabel('True and estimated output')
    figure
    semilogy((abs(e))) ;
    title('Error curve') ;
    xlabel('Samples')
    ylabel('Error value')
    %}

end

%Correct filter_size vs WSNR
figure(2)
%subplot(2,2,1)
plot(filterorderbag , NMSEmatrix(:, 1), 'r');
title('Filter Size vs NMSE')
xlabel('Filter Size')
ylabel('NMSE')