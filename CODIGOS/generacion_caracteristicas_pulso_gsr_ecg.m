%% Cargar señales ECG, pulso y GSR
GSRraw = load('JhonDGSR.mat');  % Cargar archivo GSR.mat con señal de GSR y tiempo
GSR = GSRraw.voltaje;

signal = load('Nombre_archivo.mat').dataraw;   %señal del ECG
signal1 = load('Nombre_archivo.mat').dataraw1; %señal de pulso 

%% Graficas de las señales de pulso y ECG
fs=200;
Ts=1/fs;
N = length(signal);
N1 = length(signal1);
vect= (1:1:N);
vect1= (1:1:N1);
t = vect*Ts;
t1 = vect1*Ts;

figure;
plot(t,signal);
title('Parte de señal obtenida canal 1 vs tiempo')
figure;
plot(t1,signal1);
title('Parte de señal obtenida canal 3 vs tiempo')


%% Espectro de frecuencia de pulso y ECG
F= fft(signal);
F = abs(F);
F= F(1:ceil(end/2));
F= F/max(F);
L = length(F);
f = (1:1:L)*((fs/2)/L);
figure
plot(f,abs(F));
title('Espectro de la señal en la frecuencia canal 1')

F= fft(signal1);
F = abs(F);
F= F(1:ceil(end/2));
F= F/max(F);
L = length(F);
f = (1:1:L)*((fs/2)/L);
figure
plot(f,abs(F));
title('Espectro de la señal en la frecuencia canal 3')
%% filtrado
signalf = lowpass(signal,3,fs);  
figure
plot(t,signalf);
title('señal filtrada canal 1')
xlabel('Tiempo en Segundos')
ylabel('Amplitud en mV')

signalf1 = lowpass(signal1,3,fs);   %0.5-5
figure
plot(t1,signalf1);
title('señal filtrada canal 2')
xlabel('Tiempo en Segundos')
ylabel('Amplitud en mV')
GSR =lowpass(GSR,5,200);
%% Quitar offset de la señal
signalf= (signalf-mean(signalf));
figure;
plot(signalf);

signalf1= (signalf1-mean(signalf1));
figure;
plot(signalf1);

GSR(1,:) = GSR(1,:)-mean(GSR(1,:));
%% Derivada de la señal
signalf1 = diff(signalf1);
figure()
plot(signalf1)
title('Señal derivada canal 2')

%% Quitar Parte negativa señal

for i=1:1:length(signalf)
    if signalf(i)<0
        signalf(i)=0;
        
    end
end
figure
plot(signalf)

for i=1:1:length(signalf1)
    if signalf1(i)<0
        signalf1(i)=0;
        
    end
end
figure
plot(signalf1)
%% Normalizar
signalf = normalize(signalf, "range",[0,1]);
signalf1 = normalize(signalf1, "range",[0,1]);
figure
plot(signalf)
figure
plot(signalf1)

%% Suma de señales ECG y pulso
if length(signal) > 1
    [Xa,Ya] = alignsignals(signalf,signalf1);
    menor = min(size(Xa,2),size(Ya,2));
    Xa = Xa(1,1:menor);
    Ya = Ya(1,1:menor);
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
    signalS = signalf1;
    
end
%% Normalizar señal sumada 
signalS = normalize(signalS, "range",[0,1]);
figure
plot(signalS)

%% Ventana Deslizante       
Ws=60;           %%Tamaño de la ventana en segundos 
D = 200;         %% Desplazamiento de la ventana en muestras
inicio = 180;    %% Inicio del estres en segundos 
final = 360;     %% Fin de estres en segundos 
i=1;            
Flag=0;
a= 0;
fac=1;           %% Factor del promedio por ventana
dis=80;          %% Distancia minima entre picos(muestras)
distPK = [];
it = fs*Ws;      

tam = (size(signalS,2)-it)/D;
while Flag==0
        if a == (floor(tam)+1) && (mod(size(signalS,2),it)~=0)
        ventana = signalS(1,1+a*D:end);
        ventana1 = signalf1(1,1+a*D:end);
        %Encontrar caracterisicas señal pulso y ECG
        mw = fac*mean(ventana);
        [Mg, Pk]= findpeaks(ventana,'MinPeakHeight',mw,'MinPeakDistance',dis); %Encuentra picos por prominencia minima
        distPK = diff(Pk);
        distPKM(i) = mean(distPK);
        SDNN(i) = std(distPK);
        sqpkdif=diff(distPK/fs*1000).^2; %Square differences in successive intervals
        HR(i) = 1/mean(distPK/fs)*60;
        RMSSD(i)=sqrt(mean(sqpkdif)); % RMS of successive differences (ms)
        DistInt=abs(diff(distPK/fs*1000));
        pNN50(i)=length(find(DistInt>50)); %/(length(pkdif)-1)*100; % %of differences > 50 ms
        % Frequency-based measures
        [Power,F] = plomb((distPK*fs/1000),Pk(2:end)/fs,0.5,8,'power');
        VLFindex=find(F>=0.0033 & F<0.04);  %rank for VLF
        LFindex=find(F>=0.04 & F<=0.15);    %rank for LF
        HFindex=find(F>0.15 & F<=0.4);      %rank for HF
        TPower(i)=trapz(F,Power);      %integral of the spectrum (total power)
        VLF(i)=trapz(F(VLFindex(1):VLFindex(end)),Power(VLFindex(1):VLFindex(end))); %/TPower; %percentage of LF power
        LF(i)=trapz(F(LFindex(1):LFindex(end)),Power(LFindex(1):LFindex(end))); %/TPower; %percentage of LF power
        HF(i)=trapz(F(HFindex(1):HFindex(end)),Power(HFindex(1):HFindex(end))); %/TPower; %percentage of HF power
        LFHF(i)=LF(i)/HF(i);   %LF/HF index 
        COHE(i)=LF(i)/(VLF(i)+HF(i));  %approximation of coherence index

        RRcur=distPK(1,1:length(distPK)-1);   %current RR distance
        RRfut=distPK(1,2:length(distPK));
        x1=(RRcur-RRfut)/sqrt(2);
        x2=(RRcur+RRfut)/sqrt(2);
        SD1(i)=std(x1);        %Standard deviations for Poincaré Plots
        SD2(i)=std(x2);
        Area(i)=pi*SD1(i)*SD2(i);    %Area of the best ellipse
        Ratiopoinc(i)=SD1(i)/SD2(i); %Poincaré Ratio
        % Caracteristicas GSR
        GSRlimi = find(GSR(2,:)>a);
        GSRlims = find(GSR(2,:)<(Ws+a));
        ventanaGSR = GSR(1,GSRlimi(1):GSRlims(end));
        GSRm(i) = mean(ventanaGSR);
        SDNNG(i) = std(ventanaGSR);
        maxG(i)= max(ventanaGSR);
        minG(i)= min(ventanaGSR);
        rangoGSR(i)= range(ventanaGSR);
        penGSR(i)= (ventanaGSR(end)-ventanaGSR(1))/length(ventanaGSR);
       
        Flag=1;
        elseif a == (floor(tam)+1) && (mod(size(signalS,2),it)==0)    
         Flag=1;

        else 
            ventana = signalS(1,1+a*D:it+a*D);
            mw = fac*mean(ventana);
            [Mg, Pk]= findpeaks(ventana,'MinPeakHeight',mw,'MinPeakDistance',dis);
            distPK = diff(Pk);
            distPKM(i) = mean(distPK);
            SDNN(i) = std(distPK);
            sqpkdif=diff(distPK/fs*1000).^2; %Square differences in successive intervals
            HR(i) = 1/mean(distPK/fs)*60;
            RMSSD(i)=sqrt(mean(sqpkdif)); % RMS of successive differences (ms)
            DistInt=abs(diff(distPK/fs*1000));
            pNN50(i)=length(find(DistInt>50)); %/(length(pkdif)-1)*100; % %of differences > 50 ms
            % Frequency-based measures
            [Power,F] = plomb((distPK*fs/1000),Pk(2:end)/fs,0.5,8,'power');
            VLFindex=find(F>=0.0033 & F<0.04);  %rank for VLF
            LFindex=find(F>=0.04 & F<=0.15);    %rank for LF
            HFindex=find(F>0.15 & F<=0.4);      %rank for HF
            TPower(i)=trapz(F,Power);      %integral of the spectrum (total power)
            VLF(i)=trapz(F(VLFindex(1):VLFindex(end)),Power(VLFindex(1):VLFindex(end))); %/TPower; %percentage of LF power
            LF(i)=trapz(F(LFindex(1):LFindex(end)),Power(LFindex(1):LFindex(end))); %/TPower; %percentage of LF power
            HF(i)=trapz(F(HFindex(1):HFindex(end)),Power(HFindex(1):HFindex(end))); %/TPower; %percentage of HF power
            LFHF(i)=LF(i)/HF(i);   %LF/HF index 
            COHE(i)=LF(i)/(VLF(i)+HF(i));  %approximation of coherence index
            RRcur=distPK(1,1:length(distPK)-1);   %current RR distanc
            RRfut=distPK(1,2:length(distPK));
            x1=(RRcur-RRfut)/sqrt(2);
            x2=(RRcur+RRfut)/sqrt(2);
            SD1(i)=std(x1);        %Standard deviations for Poincaré Plots
            SD2(i)=std(x2);
            Area(i)=pi*SD1(i)*SD2(i);    %Area of the best ellipse
            Ratiopoinc(i)=SD1(i)/SD2(i);
            % Caracteristicas de GSR
            GSRlimi = find(GSR(2,:)>a);
            GSRlims = find(GSR(2,:)<(Ws+a));
            ventanaGSR = GSR(1,GSRlimi(1):GSRlims(end));
            GSRm(i) = mean(ventanaGSR);
            SDNNG(i) = std(ventanaGSR);
            maxG(i)= max(ventanaGSR);
            minG(i)= min(ventanaGSR);
            rangoGSR(i)= range(ventanaGSR);
            penGSR(i)= (ventanaGSR(end)-ventanaGSR(1))/length(ventanaGSR);
            
            i=i+1;
            a = a+1; 
        end
end    

%% Creación de las etiquetas por ventana
target=zeros(1,i);                                                          %% cero = sin estres
target(((inicio*fs)/D):((final*fs-0.5*it)/D)) = 1;                          %% uno = estresado
%% Guardado de datos
tabla = [Area; COHE; distPKM; HF; HR; LF; LFHF; pNN50; Ratiopoinc; RMSSD; SD1; SD2; SDNN; TPower; VLF; GSRm; SDNNG; maxG; minG; rangoGSR; penGSR; target];
writematrix(tabla,'Datos.csv');


