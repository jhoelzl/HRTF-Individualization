function rir = import_rir(listvalue,rir_files,fs)

% Import RIR Samples
rir = [];

if (listvalue > 1)
    
    listvalue = listvalue-1;
    [rir,fs1] = wavread(sprintf('sounds/rir/%s',rir_files{listvalue})); 
    
end

end