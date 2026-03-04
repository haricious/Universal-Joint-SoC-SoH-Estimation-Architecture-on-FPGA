figure;
tiledlayout(3,2,'Padding','compact','TileSpacing','compact');

nexttile
plot(out.Vbat.Time, out.Vbat.Data,'b','LineWidth',1.6);
grid on; title('Voltage'); ylabel('V');

nexttile
plot(out.Ibat.Time, out.Ibat.Data,'r','LineWidth',1.6);
grid on; title('Current'); ylabel('A');

nexttile
plot(out.Temp.Time, out.Temp.Data,'m','LineWidth',1.6);
grid on; title('Temperature'); ylabel('K');

nexttile
plot(out.SoC.Data, out.OCV.Data);
grid on; title('OCV vs SoC');      
xlabel('SoC'); ylabel('OCV (V)');

nexttile
plot(out.C_est.Time, out.C_est.Data/3600, 'LineWidth',1.6);
grid on; title('Capacity SoH'); ylabel('Capacity (Ah)');
xlabel('Time (s)');

nexttile
plot(out.R0_est.Time, out.R0_est.Data,'c','LineWidth',1.6);
grid on; title('Internal Resistance SoH'); ylabel('R_0 (\Omega)');
xlabel('Time (s)');

%%SoC COMPARISON
figure;
plot(out.SoC.Time, out.SoC.Data,'LineWidth',1.4); hold on;
plot(out.SoC_EKF_Ideal.Time, out.SoC_EKF_Ideal.Data,'g','LineWidth',1.8);
grid on;
title('SoC (CC vs EKF)');
ylabel('SoC');
xlabel('Time (s)');
ylim([0 1]);
legend('CC','EKF');

%% SoH 
figure;
tiledlayout(2,1,'Padding','compact','TileSpacing','compact');

nexttile
plot(out.C_est.Time, out.C_est.Data/3600,'LineWidth',1.8);
grid on;
title('Capacity Fade (SoH)');
ylabel('Capacity (Ah)');
xlabel('Time (s)');

nexttile
plot(out.R0_est.Time, out.R0_est.Data,'c','LineWidth',1.8);
grid on;
title('Internal Resistance Growth (SoH)');
ylabel('R_0 (\Omega)');
xlabel('Time (s)');
