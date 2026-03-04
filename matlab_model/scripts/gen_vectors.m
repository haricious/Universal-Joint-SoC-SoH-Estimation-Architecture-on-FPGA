t = out.Ibat.Time;
I = out.Ibat.Data;
V = out.Vbat.Data;
SoC = out.SoC.Data;
Temp_K = out.Temp.Data;

Temp_C = Temp_K - 273.15;

figure;
subplot(4,1,1), plot(t,I), ylabel('I (A)'), grid on
subplot(4,1,2), plot(t,V), ylabel('V (V)'), grid on
subplot(4,1,3), plot(t,SoC), ylabel('SoC'), grid on
subplot(4,1,4), plot(t,Temp_C), ylabel('Temp (°C)'), grid on
xlabel('Time (s)')