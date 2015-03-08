function equalization

sub = 1;
% 1 = josef
% 2 = georgios

close all
if (sub == 1)
left = wavread('sounds/josef_k271_left.wav'); 
right = wavread('sounds/josef_k271_left.wav'); 
end

if (sub == 2)
left = wavread('sounds/georgios_k272_left.wav'); 
right = wavread('sounds/georgios_k272_right.wav'); 
end

sweep = wavread('sounds/sweep.wav');

if (sub == 1)
ir = dcvl(right,sweep,2130,2400);
end

if (sub == 2)
ir = dcvl(right,sweep,4750,5000);
end

iir = inverse_ir(ir,1);

figure(2)

subplot(2,1,1)
plot(ir)
subplot(2,1,2)
plot(iir)

if (sub == 1)
save('sounds/josef_k271.mat','iir');
end

if (sub == 2)
save('sounds/georgios_k272.mat','iir');
end

end

