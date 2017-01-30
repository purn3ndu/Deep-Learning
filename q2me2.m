[y,Fs] = audioread('speech.WAV');

y = y';
disp(length(y));
input = y(1:length(y)-1);
dn = y(2:length(y));

fileID = fopen('Q2output.txt','w');
fprintf(fileID,'File start\n\n');



filterorderbag = [2,5,6, 10,12, 15, 20,40];
windowsizebag = [100, 500, 1000];
NMSEmatrix = zeros(length(filterorderbag),length(windowsizebag));
for filterindex = 1:length(filterorderbag)
    filterorder = filterorderbag(filterindex);
    for windowindex = 1:length(windowsizebag)
        windowsize = windowsizebag(windowindex);
        
        min = 1;
        max = length(input)-windowsize-1;
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
        %%{
        fileID = fopen('Q2output.txt','a+');
        fprintf(fileID,'Filter - %d \n', filterorder);
        fprintf(fileID,'Windowsize - %d \n', windowsize);
        fprintf(fileID,'%f \n', weights);
        fprintf(fileID,'\n\n');
        fprintf(fileID,'NMSE = %f \n', NMSE);
        fprintf(fileID,'-----------------\n\n');   
%}
        
    end
    

end

disp(NMSEmatrix);

%filter_size vs NMSE
figure(2)
plot(filterorderbag , NMSEmatrix(:, 1), 'r',filterorderbag , NMSEmatrix(:, 2),'b',filterorderbag , NMSEmatrix(:, 3),'g' );
legend('windows size = 100','windows size = 500','windows size = 1000')
title('Filter Size vs NMSE')
xlabel('Filter Size')
ylabel('NMSE')







