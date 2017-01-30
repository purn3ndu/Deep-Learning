
input = input10k();
psd = fft(input);
psd = ((abs(psd)).^2)./length(input);   %Power Spectrum Density
figure(1);
plot(psd)


fileID = fopen('test.txt','w');
fprintf(fileID,'File start\n\n');


b = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1];
a = [1, -1];
sysout = filter(b, a, input);



whiteNoise = wgn(1, 10000, 0.1);
dn = sysout + whiteNoise;

psd2 = fft(dn);
dn2 = ((abs(psd2)).^2)./length(input);
figure(2);
plot(dn2)




filterorderbag = [5, 10, 15, 20,30,50];
windowsizebag = [100, 500, 1000, 5000, 8000];
NMSEmatrix = zeros(length(filterorderbag),length(windowsizebag));
WSNRmatrix = zeros(length(filterorderbag),length(windowsizebag));
for filterindex = 1:length(filterorderbag)
    filterorder = filterorderbag(filterindex);
    for windowindex = 1:length(windowsizebag)
        windowsize = windowsizebag(windowindex);

        min = 1;
        max = 10000-windowsize-1;
        r = (max-min).*rand(1000,1) + min;
        r = floor(r);
        weights =zeros(filterorder,1);
        NMSEsum = 0;

        for samplestart = 1:size(r,1)

            sampleend = r(samplestart)+windowsize;
            wininput = input(1,r(samplestart):sampleend);
            winoutput = dn(1,r(samplestart):sampleend);
            [rx,p] = autocross(wininput,winoutput,filterorder); % function to find the biased autocorrelation function.

            w = wrev(rx\p');  % Finding out weights for weiner filter.
            weights = weights + w;

        end


        w = weights./size(r,1);

            Esqsum = 0;
            for checkstart = 1:length(input)-filterorder
                tempx = input(checkstart:checkstart+filterorder-1);
                tempd = dn(checkstart+filterorder-1);
                e = tempd - tempx*wrev(w);
                Esqsum = Esqsum + e*e;
            end

            xsq = input*input';
            NMSE = Esqsum/xsq;
        %disp(weights);

        NMSEmatrix(filterindex,windowindex) = NMSE;


        %plot(NMSE,windowsize,'r');


        weights = weights./size(r,1);


        wStar = filter(b, a, [1, zeros(1,filterorder-1)]);
        wStar = wStar';
        SNR = 10*(log((wStar' * wStar)/((wStar - weights)' * (wStar - weights))));
        WSNRmatrix(filterindex,windowindex)=SNR;
        %%{
        fileID = fopen('test.txt','a+');
        fprintf(fileID,'Filter - %d \n', filterorder);
        fprintf(fileID,'Windowsize - %d \n', windowsize);
        fprintf(fileID,'%f \n', weights);
        fprintf(fileID,'\n\n');
        fprintf(fileID,'SNR = %f \n', SNR);
        fprintf(fileID,'NMSE = %f \n', NMSE);
        fprintf(fileID,'-----------------\n\n');   
%}

    end


end

disp(NMSEmatrix);
disp(WSNRmatrix);

%Correct filter_size vs WSNR
figure(3)
%subplot(2,2,1)
plot(filterorderbag , WSNRmatrix(:, 1), 'r',filterorderbag , WSNRmatrix(:, 2),'b',filterorderbag , WSNRmatrix(:, 3),'g' );
legend('windows size = 100','windows size = 500','windows size = 1000')
title('Filter Size vs WSNR')
xlabel('Filter Size')
ylabel('WSNR')

%Correct filter_size vs NMSE
figure(4)
plot(filterorderbag , NMSEmatrix(:, 1), 'r',filterorderbag , NMSEmatrix(:, 2),'b',filterorderbag , NMSEmatrix(:, 3),'g' );
legend('windows size = 100','windows size = 500','windows size = 1000')
title('Filter Size vs NMSE')
xlabel('Filter Size')
ylabel('NMSE')

% windowsize vs NMSE
figure(5)
hold on;
for i = 1:size(NMSEmatrix,1)
    plot(windowsizebag , NMSEmatrix(i, :) );
end
%legend('windows size = 100','windows size = 500','windows size = 1000')
title('Window size vs NMSE')
xlabel('Window size')
ylabel('NMSE')

% windowsize vs WSNR
figure(6)
hold on;
for i = 1:size(WSNRmatrix,1)
    plot(windowsizebag , WSNRmatrix(i, :) );
end
%legend('windows size = 100','windows size = 500','windows size = 1000')
title('Window size vs WSNR')
xlabel('Window size')
ylabel('WSNR')





