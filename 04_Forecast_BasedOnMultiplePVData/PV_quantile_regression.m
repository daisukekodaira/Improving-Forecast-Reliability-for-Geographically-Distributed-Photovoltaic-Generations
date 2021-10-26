function PV_quantile_regression(train_data,path)
for i=1:size(train_data,1)/48
    past_data(1:48,i) = train_data(48*i-47:48*i,end); 
end
Train_data = horzcat(train_data(1:48,5),past_data);
train_data = array2table(train_data);
Mdl = TreeBagger(100,train_data,'train_data13','Method','regression');
tau = [0.025 0.5 0.975];
quartiles = quantilePredict(Mdl,train_data,'Quantile',tau);
meanY = predict(Mdl,train_data);
for i=1:size(train_data,1)/48
     quartiles_1(1:48,i) = quartiles(48*i-47:48*i,1); 
     quartiles_2(1:48,i) = quartiles(48*i-47:48*i,2); 
     quartiles_3(1:48,i) = quartiles(48*i-47:48*i,3); 
     MeanY(1:48,i) = meanY(48*i-47:48*i,1); 
end
Quartiles_1=sum(quartiles_1,2)/i;
Quartiles_2=sum(quartiles_2,2)/i;
Quartiles_3=sum(quartiles_3,2)/i;
Meany=sum(MeanY,2)/i;
train_data = table2array(train_data);
iqr = Quartiles_3 - Quartiles_1;
k = 0.7;
lower = Quartiles_1 - k*iqr;
upper = Quartiles_3 + k*iqr;
for i = 1:size(lower,1)
    if lower(i)<0
        lower(i)=0;
    end
end
%plot(Train_data(1:48,1),past_data ,'.');
%plot(Train_data(1:48,1),[Quartiles_2 Meany lower upper]);
%legend('data','Quartiles_2','meanY','lower','upper');
%% save file
save_name='\PV_bound_';
building_num = num2str(train_data(1,1)); % Get building index
save_name = strcat(path,save_name,building_num,'.mat');
save(save_name)