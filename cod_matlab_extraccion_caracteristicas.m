clear
close all
clc
%% Lectura de datos
dataraw = readmatrix('S17_respi.txt'); % datos respiban 
dataraw(1,:)= []; % eliminar nan
E4 = readmatrix('BVPS17.txt');  % datos E4
E4(1,:) = [];  % eliminar nan
%% Recortar señal para las etiquetas de 1 a 4 
data = [];
t1 = (dataraw(:,10)>=1)&(dataraw(:,10)<=4);
% Igualar la cantidad de muestras de las señales tomadas con respiban y E4
[P,Q] = rat(700/64);
E4= resample(E4(:,2),P,Q);
dataraw = [dataraw E4];

prod = t1.*dataraw(:,:);
ceros = find(prod(:,10)==0);
data = dataraw;
data(ceros,:)=[];

%% Asignación de variables a cada señal
signal = data(:,2);             %% Señal ECG
signal1 = data(:,11);           %% Señal de pulso 
GSR = data(:,3);                %% Señal de GSR o EDA
EMG = data(:,4);                %% Señal EMG
temp = data(:,5);               %% Señal temp
XYZ1 = data(:,6);               %% Señal XYZ1
XYZ2 = data(:,7);               %% Señal XYZ2
XYZ3 = data(:,8);               %% Señal XYZ3
resp = data(:,9);               %% Señal de respiración 

%% Vector de tiempo
fresp=700;
Tresp=1/fresp;
N = length(signal);
N1 = length(signal1);
vect= (1:1:N);
vect1= (1:1:N1);
t = vect*Tresp;
t1 = vect1*Tresp;

figure;
plot(t,signal);
title('Parte de señal obtenida ECG vs tiempo')
figure;
plot(t1,signal1);
title('Parte de señal obtenida pulso vs tiempo')


%% Transformada de fourier
% FFT
F= fft(signal);
F = abs(F);
F= F(1:ceil(end/2));
F= F/max(F);
L = length(F);
f = (1:1:L)*((fresp/2)/L);
figure
plot(f,abs(F));
title('Espectro de la señal en la frecuencia ECG')

F= fft(signal1);
F = abs(F);
F= F(1:ceil(end/2));
F= F/max(F);
L = length(F);
f = (1:1:L)*((fresp/2)/L);
figure
plot(f,abs(F));
title('Espectro de la señal en la frecuencia pulso')



%% filtrado
signalf = lowpass(signal,10,fresp);   
figure
plot(t,signalf);
title('señal filtrada ECG')
xlabel('Tiempo en Segundos')
ylabel('Amplitud')

signalf1 = lowpass(signal1,3,fresp);   
figure
plot(t1,signalf1);
title('señal filtrada Pulso')
xlabel('Tiempo en Segundos')
ylabel('Amplitud')
%%
GSR =lowpass(GSR,5,fresp);
figure
plot(GSR)
title('Señal filtrada GSR')

temp = lowpass(temp,5,fresp);
figure
plot(temp)
title('Señal filtrada temperatura corporal')

%% Quitar offset de la señal
signalf= (signalf-mean(signalf));
signalf1= (signalf1-mean(signalf1));
GSR = (GSR-mean(GSR));
%% Derivada de la señal pulso
signalf1 = diff(signalf1);
figure()
plot(signalf1)
title('Señal derivada Pulso')

%% Quitar Parte negativa señal

for i=1:1:length(signalf)
    if signalf(i)<0
        signalf(i)=0;
        
    end
end
for i=1:1:length(signalf1)
    if signalf1(i)<0
        signalf1(i)=0;
        
    end
end
%% Normalizar
signalf = normalize(signalf, "range",[0,1]);
signalf1 = normalize(signalf1, "range",[0,1]);


%% Suma de señales ECG y de pulso caridaco
if length(signalf1) > 1
    [Xa,Ya] = alignsignals(signalf,signalf1);
    menor = min(size(signalf,1),size(signalf1,1));
    Xa = Xa(1:menor,1);
    Ya = Ya(1:menor,1);
    signalS = 0;
    signalS = Xa+Ya;
    figure
    plot(signalS)
    hold on
    plot(Xa)
    hold on 
    plot(Ya)
    legend('Señal +','Señal ECG','Señal pulso')
    title('Señal resultante de la suma')
else 
    signalS = signalf;
    
end
%% Normalizar señal ECG + Pulso
signalS = normalize(signalS, "range",[0,1]);
%% Procesamiento señales adicionales
% filtrado
EMG = lowpass(EMG,50,fresp);
figure
plot(EMG)
title('Señal filtrada EMG')

resp = bandpass(resp,[0.1 0.35],fresp);
figure
plot(resp)
title('Señal filtrada Respiración')
%% Quitar offset de la señal
EMG= (EMG-mean(EMG));
resp= (resp-mean(resp));
%% Transponer señales
signalS = signalS.';
GSR = GSR.';
temp = temp.';
resp= resp.';
EMG = EMG.';
XYZ1 = XYZ1.';
XYZ2 = XYZ2.';
XYZ3 = XYZ3.';
%% Ventana Deslizante       
Ws = 60;          %%Tamaño de la ventana en segundos 
fs = fresp;       %% Frecuencia de muestreo 
D = 1*fs;         %% Desplazamiento de la ventana en muestras
i = 1;            
Flag =0;
a = 0;
fac = 4;          %% Factor del promedio por ventana
dis = 300;        %% Distancia minima entre picos(muestras)
distPK = [];
it = fs*Ws;       %% tamaño ventana en muestras

tam = (size(signalS,2)-it)/D;

% Ciclo para calcular las caracteristicas por ventana
while Flag==0
        if a == (floor(tam)+1) && (mod(size(signalS,2),it)~=0)
            % Definición de ventanas
            ventana = signalS(1,1+a*D:end);
            ventanaGSR= GSR(1,1+a*D:end);
            ventanaT = temp(1,1+a*D:end);
            ventanaEMG = EMG(1,1+a*D:end);
            ventanaXYZ1 = XYZ1(1,1+a*D:end);
            ventanaXYZ2 = XYZ2(1,1+a*D:end);
            ventanaXYZ3 = XYZ3(1,1+a*D:end);
            ventanaresp = resp(1,1+a*D:end);
            tag(i)= mode(data(1+a*D:end,10));
            % GSR
            GSRm(i) = mean(ventanaGSR);
            SDNNG(i) = std(ventanaGSR);
            maxG(i)= max(ventanaGSR);
            minG(i)= min(ventanaGSR);
            rangoGSR(i)= range(ventanaGSR);
            penGSR(i)= (ventanaGSR(end)-ventanaGSR(1))/length(ventanaGSR);
            % TEMP
            tempm(i) = mean(ventanaT);
            SDNNt(i) = std(ventanaT);
            maxt(i)= max(ventanaT);
            mint(i)= min(ventanaT);
            RangoT(i)= range(ventanaT);
            penT(i)= (ventanaT(end)-ventanaT(1))/length(ventanaT);
            % EMG
            EMGm(i) = mean(ventanaEMG);
            SDNNEMG(i)= std(ventanaEMG);
            RangoEMG(i)= range(ventanaEMG);
            integralEMG(i)= trapz(abs(ventanaEMG));
            medianaEMG(i)= median(ventanaEMG);
            P10(i) = prctile(ventanaEMG,10,"all");
            P90(i) = prctile(ventanaEMG,90,"all");
            % Acelerometro
            XYZ1m(i) = mean(ventanaXYZ1);
            XYZ2m(i) = mean(ventanaXYZ2);
            XYZ3m(i) = mean(ventanaXYZ3);
            SDNNXYZ1(i) = std(ventanaXYZ1);
            SDNNXYZ2(i) = std(ventanaXYZ2);
            SDNNXYZ3(i) = std(ventanaXYZ3);
            integralXYZ1(i)= trapz(abs(ventanaXYZ1));
            integralXYZ2(i)= trapz(abs(ventanaXYZ2));
            integralXYZ3(i)= trapz(abs(ventanaXYZ3));
            %Respiración
            mresp = fac*mean(ventanaresp);
            [MRin, Pin]= findpeaks(ventanaresp,'MinPeakHeight',mresp,'MinPeakDistance',2100);
            ventanarINV= -ventanaresp;
            [MRout, Pout]= findpeaks(ventanarINV,'MinPeakHeight',mresp,'MinPeakDistance',2100);
            pinm(i) = mean(MRin);
            poutm(i) = mean(MRout);
            SDNNin(i)= std(MRin);
            SDNNout(i)= std(MRout);
            ratioIE(i)= pinm(i)/poutm(i);
            rangores(i)= range(ventanaresp);
            BR(i) = 1/mean(diff(Pin)/fresp)*60;

            %Encontrar distancia entre picos 
            mw = fac*mean(ventana);
            [Mg, Pk]= findpeaks(ventana,'MinPeakHeight',mw,'MinPeakDistance',dis); 
            distPK = diff(Pk);
            distPKM(i) = mean(distPK);
            SDNN(i) = std(distPK);
            sqpkdif=diff(distPK/fs*1000).^2; 
            HR(i) = 1/mean(distPK/fs)*60;
            RMSSD(i)=sqrt(mean(sqpkdif)); 
            DistInt=abs(diff(distPK/fs*1000));
            pNN50(i)=length(find(DistInt>50)); 
            % Frequency-based measures
            [Power,F] = plomb((distPK*fs/1000),Pk(2:end)/fs,0.5,8,'power');
            VLFindex=find(F>=0.0033 & F<0.04);  
            LFindex=find(F>=0.04 & F<=0.15);    
            HFindex=find(F>0.15 & F<=0.4);      
            TPower(i)=trapz(F,Power);      
            VLF(i)=trapz(F(VLFindex(1):VLFindex(end)),Power(VLFindex(1):VLFindex(end))); 
            LF(i)=trapz(F(LFindex(1):LFindex(end)),Power(LFindex(1):LFindex(end))); 
            HF(i)=trapz(F(HFindex(1):HFindex(end)),Power(HFindex(1):HFindex(end))); 
            LFHF(i)=LF(i)/HF(i);   
            COHE(i)=LF(i)/(VLF(i)+HF(i)); 
            RRcur=distPK(1,1:length(distPK)-1);   
            RRfut=distPK(1,2:length(distPK));
            x1=(RRcur-RRfut)/sqrt(2);
            x2=(RRcur+RRfut)/sqrt(2);
            SD1(i)=std(x1);      
            SD2(i)=std(x2);
            Area(i)=pi*SD1(i)*SD2(i);   
            Ratiopoinc(i)=SD1(i)/SD2(i); 
            Flag=1;
        elseif a == (floor(tam)+1) && (mod(size(signalS,2),it)==0)    
            Flag=1;

        else 
            ventana = signalS(1,1+a*D:it+a*D);
            ventanaGSR= GSR(1,1+a*D:it+a*D);
            ventanaT = temp(1,1+a*D:it+a*D);
            ventanaEMG = EMG(1,1+a*D:it+a*D);
            ventanaXYZ1 = XYZ1(1,1+a*D:it+a*D);
            ventanaXYZ2 = XYZ2(1,1+a*D:it+a*D);
            ventanaXYZ3 = XYZ3(1,1+a*D:it+a*D);
            ventanaresp = resp(1,1+a*D:it+a*D);
            % labels 
            tag(i)= mode(data(1+a*D:it+a*D,10));
            %GSR
            GSRm(i) = mean(ventanaGSR);
            SDNNG(i) = std(ventanaGSR);
            maxG(i)= max(ventanaGSR);
            minG(i)= min(ventanaGSR);
            rangoGSR(i)= range(ventanaGSR);
            penGSR(i)= (ventanaGSR(end)-ventanaGSR(1))/length(ventanaGSR);
            % TEMP
            tempm(i) = mean(ventanaT);
            SDNNt(i) = std(ventanaT);
            maxt(i)= max(ventanaT);
            mint(i)= min(ventanaT);
            RangoT(i)= range(ventanaT);
            penT(i)= (ventanaT(end)-ventanaT(1))/it;
            % EMG
            EMGm(i) = mean(ventanaEMG);
            SDNNEMG(i)= std(ventanaEMG);
            RangoEMG(i)= range(ventanaEMG);
            integralEMG(i)= trapz(abs(ventanaEMG));
            medianaEMG(i)= median(ventanaEMG);
            P10(i) = prctile(ventanaEMG,10,"all");
            P90(i) = prctile(ventanaEMG,90,"all");
            % Acelerometro
            XYZ1m(i) = mean(ventanaXYZ1);
            XYZ2m(i) = mean(ventanaXYZ2);
            XYZ3m(i) = mean(ventanaXYZ3);
            SDNNXYZ1(i) = std(ventanaXYZ1);
            SDNNXYZ2(i) = std(ventanaXYZ2);
            SDNNXYZ3(i) = std(ventanaXYZ3);
            integralXYZ1(i)= trapz(abs(ventanaXYZ1));
            integralXYZ2(i)= trapz(abs(ventanaXYZ2));
            integralXYZ3(i)= trapz(abs(ventanaXYZ3));
            %Respiración
            mresp = fac*mean(ventanaresp);
            [MRin, Pin]= findpeaks(ventanaresp,'MinPeakHeight',mresp,'MinPeakDistance',2100);
            ventanarINV= -ventanaresp;
            [MRout, Pout]= findpeaks(ventanarINV,'MinPeakHeight',mresp,'MinPeakDistance',2100);
            pinm(i) = mean(MRin);
            poutm(i) = mean(MRout);
            SDNNin(i)= std(MRin);
            SDNNout(i)= std(MRout);
            ratioIE(i)= pinm(i)/poutm(i);
            rangores(i)= range(ventanaresp);
            BR(i) = 1/mean(diff(Pin)/fresp)*60;
            mw = fac*mean(ventana);
            [Mg, Pk]= findpeaks(ventana,'MinPeakHeight',mw,'MinPeakDistance',dis); 
            distPK = diff(Pk);
            distPKM(i) = mean(distPK);
            SDNN(i) = std(distPK);
            sqpkdif=diff(distPK/fs*1000).^2; 
            HR(i) = 1/mean(distPK/fs)*60;
            RMSSD(i)=sqrt(mean(sqpkdif)); 
            DistInt=abs(diff(distPK/fs*1000));
            pNN50(i)=length(find(DistInt>50)); 
            [Power,F] = plomb((distPK*fs/1000),Pk(2:end)/fs,0.5,8,'power');
            VLFindex=find(F>=0.0033 & F<0.04); 
            LFindex=find(F>=0.04 & F<=0.15);    
            HFindex=find(F>0.15 & F<=0.4);      
            TPower(i)=trapz(F,Power);      
            VLF(i)=trapz(F(VLFindex(1):VLFindex(end)),Power(VLFindex(1):VLFindex(end))); 
            LF(i)=trapz(F(LFindex(1):LFindex(end)),Power(LFindex(1):LFindex(end))); 
            HF(i)=trapz(F(HFindex(1):HFindex(end)),Power(HFindex(1):HFindex(end))); 
            LFHF(i)=LF(i)/HF(i);    
            COHE(i)=LF(i)/(VLF(i)+HF(i));
            RRcur=distPK(1,1:length(distPK)-1);   
            RRfut=distPK(1,2:length(distPK));
            x1=(RRcur-RRfut)/sqrt(2);
            x2=(RRcur+RRfut)/sqrt(2);
            SD1(i)=std(x1);        
            SD2(i)=std(x2);
            Area(i)=pi*SD1(i)*SD2(i);   
            Ratiopoinc(i)=SD1(i)/SD2(i);
            i=i+1;
            a = a+1;
        end
end    

%% Creación de las etiquetas por ventana
for q=1:length(tag)
    if tag(q)==1 || tag(q)==4
        target3(q)=0;
        targetb(q)=0;
    elseif tag(q)==2
            target3(q)=1;
            targetb(q)=1;
    else
        target3(q)=2;
        targetb(q)=0;
    end
end
%% Guardar las caracteristicas en un archivo .CSV
tabla_BD1 = [Area; COHE; distPKM; HF; HR; LF; LFHF; pNN50; Ratiopoinc; RMSSD; SD1; SD2; SDNN; TPower; VLF; targetb; target3];
tabla_BD2 = [Area; COHE; distPKM; HF; HR; LF; LFHF; pNN50; Ratiopoinc; RMSSD; SD1; SD2; SDNN; TPower; VLF; GSRm; SDNNG; maxG; minG; rangoGSR; penGSR; targetb; target3];
tabla_BD3 = [Area; COHE; distPKM; HF; HR; LF; LFHF; pNN50; Ratiopoinc; RMSSD; SD1; SD2; SDNN; TPower; VLF; GSRm; SDNNG; maxG; minG; rangoGSR; penGSR; tempm ;SDNNt; maxt; mint; RangoT; penT; targetb; target3];
tabla_BD4 = [Area; COHE; distPKM; HF; HR; LF; LFHF; pNN50; Ratiopoinc; RMSSD; SD1; SD2; SDNN; TPower; VLF; GSRm; SDNNG; maxG; minG; rangoGSR; penGSR; tempm ;SDNNt; maxt; mint; RangoT; penT; EMGm; SDNNEMG; RangoEMG; integralEMG; medianaEMG; P10; P90; XYZ1m; XYZ2m; XYZ3m; SDNNXYZ1; SDNNXYZ2; SDNNXYZ3; integralXYZ1; integralXYZ2; integralXYZ3; pinm; poutm; SDNNin; SDNNout; ratioIE; rangores; BR; targetb; target3];
%writematrix(tabla_BD1,'pklS16_BD1.csv');
%writematrix(tabla_BD2,'pklS16_BD2.csv');
%writematrix(tabla_BD3,'pklS16_BD3.csv');
%writematrix(tabla_BD4,'pklS16_BD4.csv');