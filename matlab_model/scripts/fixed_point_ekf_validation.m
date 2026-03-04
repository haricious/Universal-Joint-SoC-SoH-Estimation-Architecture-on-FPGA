export_dir = 'D:\Projects\Mark_I_BMS\mark_I_bms\matlab_model\vectors';

if ~exist(export_dir, 'dir')
    mkdir(export_dir);
end

assert(exist('out','var') == 1, ...
    'ERROR: Variable "out" not found. Run Simulink model first.');

disp('Starting Fixed-Point Conversion and HEX Export...');

SoC_CC   = out.SoC.Data;
SoC_EKF  = out.SoC_EKF.Data;

Vbat     = out.Vbat.Data;
Ibat     = out.Ibat.Data;
Temp     = out.Temp.Data;

C_est    = out.C_est.Data;  
R0_est   = out.R0_est.Data;   


fx_soc_cc  = fi(SoC_CC,  1, 16, 15);   % Q1.15
fx_soc_ekf = fi(SoC_EKF, 1, 16, 15);

fx_v  = fi(Vbat, 1, 16, 8);    % Q8.8
fx_i  = fi(Ibat, 1, 16, 8);    % Q8.8
fx_t  = fi(Temp, 1, 16, 8);    % Q8.8

fx_c  = fi(C_est, 1, 32, 16);  % Q16.16
fx_r0 = fi(R0_est,1, 16, 8);   % Q8.8

disp('Fixed-point quantization complete.');

write_hex_file(fullfile(export_dir,'stim_soc_cc.hex'),   fx_soc_cc);
write_hex_file(fullfile(export_dir,'stim_soc_ekf.hex'),  fx_soc_ekf);

write_hex_file(fullfile(export_dir,'stim_voltage.hex'),  fx_v);
write_hex_file(fullfile(export_dir,'stim_current.hex'),  fx_i);
write_hex_file(fullfile(export_dir,'stim_temp.hex'),     fx_t);

write_hex_file(fullfile(export_dir,'stim_capacity.hex'), fx_c);
write_hex_file(fullfile(export_dir,'stim_r0.hex'),       fx_r0);

disp('HEX export completed successfully.');
disp(['Files saved to: ', export_dir]);
