function min_phase_hrirs(db)

% Load DB
[database.hrirs,~,~,database.angles,~,~,~,~,~,~,database.fs] = db_import(db);    
database = database_process(database);
data_set.database = database;
data_set.density = 100;  
data_set.smooth = 0;
data_set.ears = {[1 2]};
data_set.onlypos = 0;
data_set = preprocess(data_set);

% Model Parameters
model.type = 'pca';
model.weight_model.type = 'pcw2sh';
model.dataset = data_set;
model.ear_mode = 2;
model.input_mode = 3;
model.structure = 2;                            

pos = get_matrixvalue(-80,0,database.angles);
sub = 25;

% PCs, PCWs
model = compute_model(model);
% 
% figure(2)
% hold on
% plot(squeeze(model.pca_matrix(20,:)),'r')

model.ncmp = 100;
model.weight_model.order = 3;                  
model = compute_weight_model(model);
model = evaluate_model(model);

figure(1)
clf;
plot(squeeze(database.hrirs(sub,pos,1,:)))
xlabel('time [samples]')
ylabel('amplitude')
grid on
hold on 
x = database.itd_samples(sub,pos);
lim = get(gca,'YLim'); 
%h = arrayfun(@(x) line([x x],lim,'Color','r'),x);
set(1,'paperunits','centimeters','paperposition',[1 1 22 13])
saveas(1,'../thesis/images/min_phase/example1_left','epsc');

figure(11)
clf;
plot(squeeze(database.hrirs(sub,pos,2,:)))
xlabel('time [samples]')
ylabel('amplitude')
grid on
hold on 
x = database.itd_samples(sub,pos);
lim = get(gca,'YLim'); 
%h = arrayfun(@(x) line([x x],lim,'Color','r'),x);
set(11,'paperunits','centimeters','paperposition',[1 1 22 13])
saveas(11,'../thesis/images/min_phase/example1_right','epsc');

figure(2)
clf;
plot(squeeze(database.mphrirs(sub,pos,1,:)))
grid on
xlabel('time [samples]')
ylabel('amplitude')
hold on 
x = database.itd_samples(sub,pos);
lim = get(gca,'YLim'); 
%h = arrayfun(@(x) line([x x],lim,'Color','r'),x);
set(2,'paperunits','centimeters','paperposition',[1 1 22 13])
saveas(2,'../thesis/images/min_phase/example2_left','epsc');

figure(22)
clf;
plot(squeeze(database.mphrirs(sub,pos,2,:)))
grid on
xlabel('time [samples]')
ylabel('amplitude')
hold on 
x = database.itd_samples(sub,pos);
lim = get(gca,'YLim'); 
%h = arrayfun(@(x) line([x x],lim,'Color','r'),x);
set(22,'paperunits','centimeters','paperposition',[1 1 22 13])
saveas(22,'../thesis/images/min_phase/example2_right','epsc');

figure(3)
clf;
plot(squeeze(model.hrirs(sub,pos,1,:)))
%title('Time aligned minimum phase HRIR left')
xlabel('time [samples]')
ylabel('amplitude')
grid on
hold on 
x = database.itd_samples(sub,pos);
lim = get(gca,'YLim'); 
%h = arrayfun(@(x) line([x x],lim,'Color','r'),x);
set(3,'paperunits','centimeters','paperposition',[1 1 22 13])
saveas(3,'../thesis/images/min_phase/example3_left','epsc');

figure(33)
clf;
plot(squeeze(model.hrirs(sub,pos,2,:)))
%title('Time aligned minimum phase HRIR left')
xlabel('time [samples]')
ylabel('amplitude')
grid on
hold on 
x = database.itd_samples(sub,pos);
lim = get(gca,'YLim'); 
h = arrayfun(@(x) line([x x],lim,'Color','r'),x);
set(33,'paperunits','centimeters','paperposition',[1 1 22 13])
saveas(33,'../thesis/images/min_phase/example3_right','epsc');


end

