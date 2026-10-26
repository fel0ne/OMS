%======= params =========
TxPowerBS = 46; %дБм
countSectorsBS = 3;
TxPowerUE = 24; %дБм
AntGainBS = 21; %дБи
PenetrationM = 15; %дБ
IM = 1; %дБ
%Модель распространения сигнала для макросот: COST 231 Hata;
%Модель распространения сигнала для фемто- и микросот: UMiNLOS

f = 18e8; %ГГц;
BW_UL = 10e6; %МГц;
BW_DL = 20e6; %МГц;
%Дуплекс UL и DL: FDD;
NoiseFigure_BS = 2.4; %дБ;
NoiseFigure_UE = 6; %дБ;
RequiredSINR_DL = 2;%Требуемое отношение SINR для DL: 2 дБ;
RequiredSINR_UL = 4;%Требуемое отношение SINR для UL: 4 дБ;
MIMOGain = 3;%дБ Число приемо-передающих антенн на BS (MIMO): 2;
S_area = 100; %кв.км;
S_shops = 4; %кв.к м;
%Базовые станции с фидерами.
FeederLoss = 2; %дБ


%========== 1 ===========
ThermalNoise_UL = -1*174 + 10 * log10(BW_UL);
RxSensBS = NoiseFigure_BS + ThermalNoise_UL + RequiredSINR_UL; 
%RxSensBS = TxPowerUE − FeederLoss + AntGainBS + MIMOGain − MAPL_UL − IM − PenetrationM; %UL
MAPL_UL= TxPowerUE - FeederLoss + AntGainBS + MIMOGain - RxSensBS - IM - PenetrationM;

disp(MAPL_UL);
%========== 2 ===========
ThermalNoise_DL = -1*174 + 10 * log10(BW_DL);
RxSensUE = NoiseFigure_UE + ThermalNoise_DL + RequiredSINR_DL; 
%RxSensUE = TxPowerBS − FeederLoss + AntGainBS + MIMOGain − MAPL_DL − IM − PenetrationM; %DL 
MAPL_DL = TxPowerBS - FeederLoss + AntGainBS + MIMOGain - RxSensUE - IM - PenetrationM;
disp(MAPL_DL);


%========= 3 ===========

d_max = 5000;
d_step = 5;
PL_UMiNLOS = zeros(1,d_max/d_step);
PL_HATA = zeros(1,d_max/d_step);
LLOS = zeros(1,d_max/d_step);
LNLOS = zeros(1,d_max/d_step);
idx = 1;
for d = 1:d_step:d_max
    %Модель UMiNLOS (Urban Micro Non-Line-of-Sight)
    %f - ГГц
    f_Ghz = f/1e9;
    PL_UMiNLOS(idx) = 26*log10(f_Ghz) + 22.7 + 36.7*log10(d);
    

    
    %Модель Окумура-Хата и ее модификация COST231
    %======= HATA params =======
    f_Mhz = f/1e6;
    hBS = 30; %30 - 200 
    hMS = 1; %1 -10
    
    % 1 - dense_urban
    % 2 - urban
    % 3 - suburban
    % 4 - rural
    % 5 - road
    area_type = 1;
    
    %===========================
    
    
    Lcutter = 0;
    A = 0;
    B = 0;
    s = 0;
    
    if f_Mhz < 1500 && f_Mhz > 150
        A = 69.55;
        B = 26.16;
    elseif f_Mhz < 2000 && f_Mhz >= 1500
        A = 46.3;
        B = 33.9;
    end
    
    
    if area_type > 0 && area_type < 3
        a = 3.2 * (log10(11.75*hMS))^2 - 4.97;
    elseif area_type > 2 && area_type < 6
        a = (1.1 * log10(f_Mhz))*hMS - (1.56*log10(f_Mhz) - 0.8);
    end
    
    
    switch area_type
        case 1
            Lcutter = 3;
        case 2
            Lcutter = 0;
        case 3
            Lcutter = -1*(2*(log10(f_Mhz/28))^2 + 5.4);
        case 4
            Lcutter = -1*(4.78*(log10(f_Mhz))^2 - 18.33*log10(f_Mhz) + 40.94);
        case 5
            Lcutter = -1*(4.78*(log10(f_Mhz))^2 - 18.33*log10(f_Mhz) + 35.94);
    end
    if d >= 1000
        s = 44.9 - 6.55 * log10(f_Mhz);
    else
        s = (47.88 + 13.9 * log10(f_Mhz) - 13.9 * log10(hBS)) * (1/log10(50));
    end
    
    if A + B > 0
        PL_HATA(idx) = A + B*log10(f_Mhz) - 13.82*log10(hBS) - a + s*log10(d/1000) + Lcutter;
    end
    

    %========= Модель Walfish-Ikegami ==========
    h = 20; %средняя высота зданий, м
    w = 10; %средняя ширина улиц, м
    b = 15; %среднее расстояние между зданиями, м
    fi = 45; %средний угол между направлением распространения сигнала и улицей.
    delta_h = h - hMS;
    d_km = d/1000;

    LLOS(idx) = 42.6 + 20*log10(f_Mhz) + 26*log10(d_km);
    
    L0 = 32.44 + 20*log10(w) + 20*log10(d_km);
    
    L2_koef = 0;
    if fi >= 0 && fi < 35
        L2_koef = -1*10 + 0.354*fi;
    elseif fi >= 35 && fi < 55
        L2_koef = 2.5 + 0.075*fi;
    elseif fi >= 55 && fi < 90
        L2_koef = 4.0 - 0.114*fi;
    end 
    L2 = -1*16.9 + -1*10*log10(w) + 10*log10(f_Mhz) + 20*log10(delta_h) + L2_koef; 
    
    L11 = 0;
    if hBS > delta_h
        L11 = -1*18*log10(1 + hBS - delta_h);
    end
    

    Ka = 54;
    
    if hBS <= delta_h && d_km > 0.5
        Ka = 54 - 0.8*(hBS - delta_h);
    elseif hBS <= delta_h && d_km <= 0.5
        Ka = 54 - 0.8*(hBS - delta_h)*(d_km/0.5);
    end

    Kd = 18;
    if hBS <= delta_h
        Kd = 18 - 15 * ((hBS - delta_h)/delta_h);
    end

    Kf = -4 + 0.7*(f_Mhz/925 -1);

    L1 = L11 + Ka + Kd*log10(d_km) + Kf * log10(f_Mhz) - 9*log10(b);

    if L1 + L2 > 0
        LNLOS(idx) = L0+L1+L2;
    else
        LNLOS(idx) = L0;
    end


    idx = idx + 1;
end


ds = 1:d_step:d_max;

%1 - UMiNLOS
%2 - HATA
%3 - LLOS
%4 - LNLOS
current_model = 1;


BS_R = 0;
pl = 0;
d_idx = 0;
for i = 1:length(ds)
    
    switch(current_model)
        case 1
            pl = PL_HATA;
        case 2
            pl = PL_UMiNLOS;
        case 3
            pl = LLOS;
        case 4
            pl = LNLOS;
    end
    if pl(i) < MAPL_DL || pl(i) < MAPL_UL
        BS_R = ds(i);
        d_idx = i;
    end
end
BS_R = BS_R - d_step; 
figure('Name', 'Модели распространения радиосигнала');


plot(ds, PL_UMiNLOS, 'b-', 'LineWidth', 1.5);
hold on;
plot(ds, PL_HATA, 'r-', 'LineWidth', 1.5);
plot(ds, LLOS, 'g--', 'LineWidth', 1.2);
plot(ds, LNLOS, "w", 'LineWidth', 1.2); 

yline(MAPL_UL, '--b', ['MAPL UL = ' num2str(round(MAPL_UL, 1)) ' дБ'], ...
    'LineWidth', 1.2, 'LabelHorizontalAlignment', 'left');
yline(MAPL_DL, '--r', ['MAPL DL = ' num2str(round(MAPL_DL, 1)) ' дБ'], ...
    'LineWidth', 1.2, 'LabelHorizontalAlignment', 'left');

stem(BS_R, pl(d_idx), 'filled', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5);

hold off;
grid on;

xlabel('Расстояние между приемником и передатчиком d, м', 'FontSize', 11);
ylabel('Потери мощности радиосигнала PL, дБ', 'FontSize', 11);
title('Сравнение моделей распространения радиосигнала и определение радиуса соты', 'FontSize', 12);

legend({'UMiNLOS', 'COST 231 Hata', 'Walfish-Ikegami (LOS)', 'Walfish-Ikegami (NLOS)'}, 'Location', 'southeast', 'FontSize', 10);


MAPL_min = min(MAPL_DL, MAPL_UL);

idx_macro = find(PL_HATA <= MAPL_min, 1, 'last');
R_macro_m = ds(idx_macro);         
R_macro_km = R_macro_m / 1000;      


S_site_macro = 1.95 * (R_macro_km)^2;


S_macro_target = S_area - S_shops;  % 100 - 4 = 96 кв.км


N_macro = ceil(S_macro_target / S_site_macro);



idx_micro = find(PL_UMiNLOS <= MAPL_min, 1, 'last');
R_micro_m = ds(idx_micro);
R_micro_km = R_micro_m / 1000;

S_site_micro = 1.95 * (R_micro_km)^2;

N_micro = ceil(S_shops / S_site_micro);

fprintf('--- Макросоты (COST 231 Hata) ---\n');
fprintf('Радиус соты: %.1f м (%.3f км)\n', R_macro_m, R_macro_km);
fprintf('Площадь покрытия одной БС: %.3f кв.км\n', S_site_macro);
fprintf('Число макро-БС на территорию: %d шт.\n\n', N_macro);

fprintf('--- Микро/фемтосоты (UMiNLOS) ---\n');
fprintf('Радиус соты: %.1f м\n', R_micro_m);
fprintf('Площадь покрытия одной БС: %.6f кв.км\n', S_site_micro);
fprintf('Число микро-БС для ТЦ/БЦ: %d шт.\n', N_micro);