%% Medición de señal GSR con esp32
close all;
clc;
voltaje = [] ;
temp = [];
delete(instrfind({'port'},{'COM3'}));   % Puerto serial ha utilizar
puerto = serial('COM3'); 
puerto.BaudRate= 9600;                  % Taza de transferencia en baudios
fopen(puerto);

contador = 1 ;
% Recortar señal
tf = 600;   %tiempo de toma de señal
tinf = 1;   % Desde que segundo se guarda la señal
tsup= 1;    % cuantos segundos del final cortar (debe ser menor a tf)
fscanf(puerto,'%f');

tic
    while toc <= tf
        valoradc = fscanf(puerto,'%f');
        voltaje(contador)= 5*valoradc(1)/4096;
        contador = contador+1;
        temp(contador) = toc;
        
    end
GSR = voltaje;
voltaje = lowpass(voltaje,3,200);
%% Eliminar parte de la señal
voltaje(2,:) = temp(1,1:end-1);
kinf = find(voltaje(2,:)<tinf);                                                                                                                                                                                                                                        
voltaje(:,1:kinf(end)) = [];
ksup = find(voltaje(2,:)>(tf-tsup));
voltaje(:,ksup(1):end) = [];
%%
fclose(puerto);
delete(puerto);
%% Guardar la señal
save('Nombre_del_archivo.mat','GSR','voltaje')