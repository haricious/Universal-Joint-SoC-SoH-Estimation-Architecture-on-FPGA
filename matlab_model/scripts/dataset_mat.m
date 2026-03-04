clear; clc;
%% PARAMETERS
fs = 1; % 1 Hz sampling for long-duration drift
dt = 1/fs;
N = 10000; % 10,000 seconds total simulation

C_nom_Ah = 7;
C_true_Ah = 5.6; % 20% degraded capacity
C_true = C_true_Ah * 3600; % Convert to Coulombs
R_true = 0.065; % 30% increased resistance

I = zeros(N,1);
V = zeros(N,1);
T = zeros(N,1);
SoC = zeros(N,1);
SoC(1) = 1.0; % Start at 100%

%% GENERATE NOISY DATASET
for k = 1:N
    % Current profile with discharge pulses
    if mod(floor(k/500),2) == 0
        I(k) = 3.0; % 3A discharge
    else
        I(k) = 1.5; % 1.5A lighter discharge
    end
end

% Add current sensor noise (±0.1A)
I_meas = I + 0.1*randn(N,1);

for k = 2:N
    % True SoC (Plant/Ground Truth)
    SoC(k) = SoC(k-1) - (I(k)*dt)/C_true;
    SoC(k) = max(0, min(1, SoC(k)));
    
    % Nonlinear OCV + True Voltage
    OCV = 11 + 2.8*SoC(k) + 0.05*SoC(k)^2;
    V_true = OCV - I(k)*R_true;
    
    % Add voltage measurement noise (±20mV)
    V(k) = V_true + 0.02*randn;
    T(k) = 298 + 2*sin(0.001*k);
end

%% CONVERT TO Q16.16 FIXED POINT AND EXPORT
scale = 65536;
I_q = int32(I_meas * scale);
V_q = int32(V * scale);
T_q = int32(T * scale);
SoC_q = int32(SoC * scale);

fid = fopen('dataset.mem','w');
for k = 1:N
    data = [typecast(I_q(k), 'uint32'), typecast(V_q(k), 'uint32'), ...
            typecast(T_q(k), 'uint32'), typecast(SoC_q(k), 'uint32')];
    fprintf(fid, '%08X%08X%08X%08X\n', data);
end
fclose(fid);
disp('Long-duration noisy dataset generated successfully.');