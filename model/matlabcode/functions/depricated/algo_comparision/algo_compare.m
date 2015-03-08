function e = algo_compare(dimensions,original,reconstr)

disp(sprintf('Comparision of Original and Reconstruction [%i x %i]',size(original,1),size(original,2))) 

% if (~isempty(dimensions))
%    if (~isempty(dimensions{8}))  
%     mode = dimensions{8};
%    else
%        mode = 1;
%    end
% else
%     mode = 1;
% end

% original = algo_inv_reshape(original,size(reconstr),dimensions{4},dimensions{6});


% [xa ya]=size(original);
% [xb yb]=size(reconstr);
%     
% if (xa~=xb || ya~=yb)
%    disp('ERROR: Two Matrices with different dimensions:') 
%    disp(sprintf('Original [%i x %i]',size(original,1),size(original,2)))
%    disp(sprintf('Reconstruction [%i x %i]',size(reconstr,1),size(reconstr,2)))
%    return
% end

% MSError over frequency - Dimensions are persons,angles,ear
v = length(size(reconstr)) - length(size(original));
ff = repmat('%d,',1,size(v,2));st = [];
for z = 1:v
    st = strcat(st,sprintf('1:%d,',size(reconstr,z)));
end
prms = cartprod(eval(st(1:end-1)));
for k = 1:size(prms,1)
    st1 = sprintf('reconstr(%s:,:,:,:)',ff);
    ste = sprintf('e(%s:,:,:)',ff);
    rc = squeeze(eval(sprintf(st1,prms(k,:))));
    if (dimensions.mode == 1) % DTF
        if dimensions.freq_mode == 1 % Linear 
            eval(strcat(sprintf(ste,prms(k,:)),'=squeeze(sqrt(mean( 20*log10( rc ./ original ).^2,4)));'));    
        elseif dimensions.freq_mode == 2 % DB
            eval(strcat(sprintf(ste,prms(k,:)),'=squeeze(sqrt(mean( (rc - original).^2,4)));'));    
%             eval(sprintf(ste,prms(k,:)) = squeeze(sqrt(mean( (rc - original).^2,4))));
        end
        
    else % Hrir
        eval(strcat(sprintf(ste,prms(k,:)),'=squeeze(sqrt(mean( (rc - original).^2,4)));'));    
%         eval(sprintf(st1,prms(k,:)) = squeeze(sqrt(mean( (rc - original).^2,4))));    
    end
end

% Plot
figure(3)
clf;
plot(mean(mean(mean(e,4),3),2));

if (dimensions.mode == 1)
    % DTF
    if (dimensions.freq_mode == 1) % lin
    disp(sprintf('Finished: Mean RMS Error (lin): %5.2f',mean(mean(mean(mean(e,4))))))
    else % log
    disp(sprintf('Finished: Mean RMS Error (log): %5.2f [dB]',mean(mean(mean(mean(e,4))))))  
    end
else
    % HRIR
    disp(sprintf('Finished: Mean RMS Error: %5.2f',mean(mean(mean(mean(e,4))))))
end