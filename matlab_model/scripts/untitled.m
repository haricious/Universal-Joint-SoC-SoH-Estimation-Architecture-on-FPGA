clear;
clc;

%% PARAMETERS
fs = 1000;              % Sampling frequency
dt = 1/fs;
N = 10000;

C_nom_Ah = 7;
C_true_Ah = 5.6;        % 20% degraded
C_true = C_true_Ah * 3600;  % Convert to Coulombs

R_true = 0.065;         % 30% increased

%% PRE-ALLOCATE
I = zeros(N,1);
V = zeros(N,1);
T = zeros(N,1);
SoC = zeros(N,1);

SoC(1) = 1;  % Start at 100%

%% GENERATE CURRENT PROFILE
for k = 1:N
    if mod(floor(k/500),2) == 0
        I(k) = 3;   % 3A discharge
    else
        I(k) = 1.5; % lighter discharge
    end
end

%% SIMULATION LOOP
for k = 2:N
    SoC(k) = SoC(k-1) - (I(k)*dt)/C_true;
    SoC(k) = max(0, min(1, SoC(k))); % Clamp
    
    OCV = 11 + 2.8*SoC(k);
    V(k) = OCV - I(k)*R_true;
    
    T(k) = 298 + 2*sin(0.001*k);
end

%% CONVERT TO Q16.16 FIXED POINT
scale = 2^16;

I_q  = int32(I * scale);
V_q  = int32(V * scale);
T_q  = int32(T * scale);
SoC_q = int32(SoC * scale);

%% CREATE 128-BIT PACKED WORDS
fid = fopen('dataset.mem','w');

for k = 1:N
    % Convert to unsigned hex for memory storage
    data = [typecast(I_q(k),'uint32'), ...
            typecast(V_q(k),'uint32'), ...
            typecast(T_q(k),'uint32'), ...
            typecast(SoC_q(k),'uint32')];
        
    fprintf(fid,'%08X%08X%08X%08X\n',data);
end

fclose(fid);

disp('dataset.mem generated successfully');