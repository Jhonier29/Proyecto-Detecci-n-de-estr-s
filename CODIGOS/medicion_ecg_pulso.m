%% PPG Data acquisition for HRV (with OpenBCI)
% Raw data from OpenBCI are taken in a data vector (not in windows)
clear
close all
clc

%% Configure data ACQ with LSL protocol from OpenBCI App
% Instantiate the library
disp('Loading the library...');
lib = lsl_loadlib();
% Resolve a stream...L = length(F);
disp('Resolving a data stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end
% Create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});  % Ready to read data from Ganglion
inlet1 = lsl_inlet(result{1});
% First refernce time stamp (without data)
[chunk,stamps] = inlet.pull_chunk();
[chunk1,stamps1] = inlet1.pull_chunk();


%% Time and Data Features
fs = 200;  % Sampling frequency (Hz) of the ECG or PPG data from the OpenBCI
Te = 1;    % Rolling time (Execution time (s) for processing)
Tfin = 600;   % Final time for the test in seconds
ChECG = 1; % Channel of ECG data
ChECG1 = 3; % Channel of Pulse sensor data
t = linspace(0, Te, Te*8192);   % time vector to beep
sig=sin(2*pi*1000*t(1:Te*8192/4));  %sine signal to beep
% Memory Allocation for data vectors
dataraw=[];
timestamp=[];
dataraw1=[];
timestamp1=[];


%% Reading and processing cycle
ov=0;
it=0;
V=0;

% Main cycle
while ov==0
   tic;     %flag to calculate process time
   it=it+1  %number of iterations
% Get new chunk from the inlet
   [chunk,stamps] = inlet.pull_chunk();
   dataraw=[dataraw chunk(ChECG,:)];
   timestamp=[timestamp stamps(1,:)]; 

   [chunk1,stamps1] = inlet1.pull_chunk();
   dataraw1=[dataraw1 chunk1(ChECG1,:)];
   timestamp1=[timestamp1 stamps1(1,:)]; 

%counting iterations and ending control
    if it==Tfin
        ov=1;
    end
    toc
    pause(Te-toc)   %Guarantee waiting until Te is reached for the new chunk
end
sound(sig);
%Release the OpenBCI objects (sometimes there is a crash in Matlab) 
clear inlet lib

%% Guardar datos de ECG y pulso 

save('Nombre_archivo.mat',"dataraw","dataraw1");
