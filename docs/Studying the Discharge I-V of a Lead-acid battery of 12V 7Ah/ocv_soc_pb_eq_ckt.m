figure

subplot(4,1,1)
plot(out.Vbat.Time, out.Vbat.Data,'b','LineWidth',1.8)
grid on
ylabel('Voltage (V)')
title('Battery Voltage vs Time')

subplot(4,1,2)
plot(out.Ibat.Time, out.Ibat.Data,'r','LineWidth',1.8)
grid on
ylabel('Current (A)')
title('Battery Current vs Time')

subplot(4,1,3)
plot(out.SoC.Time, out.SoC.Data,'LineWidth',1.8)
grid on
ylabel('SoC')
ylim([0 1])
title('State of Charge vs Time')

subplot(4,1,4)
plot(out.SoC.Data,out.OCV.Data,'MarkerSize',10)
grid on
xlabel('SoC')
ylabel('OCV (V)')
title('OCV vs SoC')
