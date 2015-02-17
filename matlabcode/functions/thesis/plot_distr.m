function plot_distr()

mu = 0;
sd = 1;
ix = -3*sd:1e-3:3*sd; %covers more than 99% of the curve

perc = [1 12.5 25 50 75 87.5 99];

perc_data = prctile(ix,perc);

iy = pdf('normal', ix, mu, sd);
figure(1)
clf;
plot(ix,iy,'r');


% Plot Percentile lines
for p=1:length(perc)
    hold on
    
    plot([perc_data(p) perc_data(p)],[0 0.4],'b')
end

end