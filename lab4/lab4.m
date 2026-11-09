clear; clc; close all;

N = 5;
len_gold = 2^N - 1;

x = [0, 0, 1, 0, 1];
y = [0, 1, 1, 0, 0];
gold = zeros(1, len_gold);

for i = 1:len_gold
    [gold(i), x, y] = gold_cycle(N, x, y);
end

fprintf('x = ');    
print_array(N, x);
fprintf('y = ');    
print_array(N, y);
fprintf('gold = '); 
print_array(len_gold, gold);
fprintf('\n\n\n');

r_auto1 = autocor_table(len_gold, gold);

x2 = [0, 0, 1, 1, 0]; % 6
y2 = [0, 0, 1, 1, 1]; % 7
gold2 = zeros(1, len_gold);

for i = 1:len_gold
    [gold2(i), x2, y2] = gold_cycle(N, x2, y2);
end

fprintf('\n\n\n');
fprintf('x2 = ');    
print_array(N, x2);
fprintf('y2 = ');    
print_array(N, y2);
fprintf('Gold 2: '); 
print_array(len_gold, gold2);
fprintf('\n\n\n');


r_auto2 = autocor_table(len_gold, gold2);


cross_corr = calc_autocorr(len_gold, gold, gold2);
fprintf('Взаимная корреляция Gold1 и Gold2  %.5f\n\n', cross_corr);

s1 = 1 - 2 * double(gold);
s2 = 1 - 2 * double(gold2);
[r_cross_all, lags] = xcorr(s1, s2, 'coeff');
cross_corr_builtin = r_cross_all(lags == 0);

fprintf('--- Пункт 5: Сравнение ---\n');
fprintf('C++ / ручной расчет: %.5f\n', cross_corr);
fprintf('Функция xcorr():     %.5f\n\n', cross_corr_builtin);

figure('Name', 'Autocorrelation Graphs', 'Position', [200, 100, 850, 600]);


subplot(2, 1, 1);
stem(0:len_gold, r_auto1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
grid on;
title('Функция автокорреляции последовательности Голда (Gold 1)');
xlabel('Величина задержки (lag, бит)');
ylabel('R(\tau)');
xlim([0 len_gold]);
ylim([-0.5 1.1]);
xticks(0:2:len_gold);


subplot(2, 1, 2);
stem(0:len_gold, r_auto2, 'filled', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5, 'MarkerSize', 4);
grid on;
title('Функция автокорреляции последовательности Голда (Gold 2)');
xlabel('Величина задержки (lag, бит)');
ylabel('R(\tau)');
xlim([0 len_gold]);
ylim([-0.5 1.1]);
xticks(0:2:len_gold);




function x = shift_r(n, x, first_n)
    temp = zeros(1, n);
    for i = 1:(n - 1)
        temp(i + 1) = x(i);
    end
    if first_n == -1
        temp(1) = x(n);
    else
        temp(1) = first_n;
    end
    for i = 1:n
        x(i) = temp(i);
    end
end

function print_array(n, x)
    for i = 1:n
        fprintf('%d ', x(i));
    end
    fprintf('\n');
end

function [out, x, y] = gold_cycle(N, x, y)
    out = bitxor(x(N), y(N));
    x_xor_result = bitxor(x(N - 1), x(N));
    y_xor_result = bitxor(y(2), y(N));
    x = shift_r(N, x, x_xor_result);
    y = shift_r(N, y, y_xor_result);
end

function result = calc_autocorr(n, orig, shifted)
    matches = 0;
    mismatches = 0;
    for i = 1:n
        if orig(i) == shifted(i)
            matches = matches + 1;
        else
            mismatches = mismatches + 1;
        end
    end
    result = double(matches - mismatches) / n;
end

function r_vals = autocor_table(len_gold, gold)
    shifted_gold = zeros(1, len_gold);
    for i = 1:len_gold
        shifted_gold(i) = gold(i);
    end
    r_vals = zeros(1, len_gold + 1);
    fprintf('Сдвиг\tПоследовательность (31 бит)\tАвтокорреляция\n');
    for shift = 0:len_gold
        r = calc_autocorr(len_gold, gold, shifted_gold);
        r_vals(shift + 1) = r;
        fprintf('%2d\t', shift);
        for i = 1:len_gold
            fprintf('%d', shifted_gold(i));
        end
        fprintf('\t%.8f\n', r);
        shifted_gold = shift_r(len_gold, shifted_gold, -1);
    end
end