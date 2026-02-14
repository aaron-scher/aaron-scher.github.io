clc
clear all
Rg=1;
RL=1000;
for n=1:60
    n_vec(n)=n;
    x=n;
    Zin = RL/x^2;
    V2_over_Vg(n)=x*Zin/(Zin+Rg);
end
plot(n_vec,V2_over_Vg)
xlabel('N_2/N_1','fontsize',20)
ylabel('V_2/V_g','fontsize',20)
set(gcf,'color','white')
grid on