t = out.SoC_EKF_Ideal.Time;

soc_ideal = out.SoC_EKF_Ideal.Data;
soc_real  = out.SoC_EKF_Real.Data;

n = min(length(soc_ideal), length(soc_real));

t = t(1:n);
soc_ideal = soc_ideal(1:n);
soc_real  = soc_real(1:n);

error = soc_real - soc_ideal;
abs_error = abs(error);

max_error = max(abs_error);
mean_error = mean(abs_error);
r = sqrt(mean(error.^2));

disp('Error results:')
disp(['Max error  : ', num2str(max_error)])
disp(['Mean error : ', num2str(mean_error)])
disp(['RMSE       : ', num2str(r)])
