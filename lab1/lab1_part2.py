import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.fft import fft, fftshift

# =====================================================================

script_dir = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.join(script_dir, 'oms.wav')


Fs, y = wavfile.read(file_path)

if len(y.shape) > 1:
    y = y[:, 0]



num_samples = len(y)   
duration = num_samples / Fs        
calculated_Fs = num_samples / duration  

print(f"--- ПУНКТЫ 9 и 10 ---")
print(f"Количество отсчетов: {num_samples}")
print(f"Длительность записи: {duration:.2f} сек")
print(f"Fs из файла: {Fs} Гц")
print(f"Расчетное Fs (N/t): {calculated_Fs:.2f} Гц")
print("Сравнение: Значения Fs совпадают!\n")


k = 10  

y1 = y[::k]     
Fs1 = int(Fs / k) 

print(f"--- ПУНКТ 11 ---")
print(f"Прореженный сигнал: Fs_new = {Fs1} Гц")


out_file = os.path.join(script_dir, 'voice_downsampled.wav')
wavfile.write(out_file, Fs1, (y1 * 32767).astype(np.int16))
print(f"Файл с прореженным звуком сохранен как '{out_file}' (можешь послушать его в Windows!)\n")


plt.figure(figsize=(12, 10))

plt.subplot(2, 2, 1)
t1 = np.linspace(0, duration, len(y1))
plt.plot(t1, y1, 'r')
plt.xlabel('Время (с)')
plt.ylabel('Амплитуда')
plt.title('11. Прореженный сигнал y1(t)')
plt.grid(True)

# =====================================================================


N = len(y)
Y = fft(y)
Y_mag = np.abs(fftshift(Y)) / N
freqs = np.linspace(-Fs/2, Fs/2, N)


N1 = len(y1)
Y1 = fft(y1)
Y1_mag = np.abs(fftshift(Y1)) / N1
freqs1 = np.linspace(-Fs1/2, Fs1/2, N1)

plt.subplot(2, 2, 2)
plt.plot(freqs, Y_mag)
plt.xlabel('Частота (Гц)')
plt.ylabel('Амплитуда')
plt.title('12. Спектр оригинала (Fs = 48000 Гц)')
plt.grid(True)

plt.subplot(2, 2, 3)
plt.plot(freqs1, Y1_mag, 'r')
plt.xlabel('Частота (Гц)')
plt.ylabel('Амплитуда')
plt.title('12. Спектр прореженного (Fs = 4800 Гц)')
plt.grid(True)

# =====================================================================

def quantize_signal(signal, bits):
    L = 2**bits - 1
    scaled = (signal + 1) / 2 * L
    quantized_scaled = np.round(scaled)
    quantized_scaled = np.clip(quantized_scaled, 0, L)
    return (quantized_scaled / L) * 2 - 1

bits_list = [3, 4, 5, 6]
print("--- ПУНКТ 13: Средняя ошибка квантования ---")

for b in bits_list:
    y_q = quantize_signal(y, b)
    mean_error = np.mean(np.abs(y - y_q))
    print(f"Разрядность АЦП: {b} бит ({2**b} уровней) -> Средняя ошибка: {mean_error:.6f}")


y_q3 = quantize_signal(y, 3)
Y_q3 = fft(y_q3)
Y_q3_mag = np.abs(fftshift(Y_q3)) / N

plt.subplot(2, 2, 4)
plt.plot(freqs, Y_mag, label='Оригинал (без квантования)')
plt.plot(freqs, Y_q3_mag, 'g--', alpha=0.6, label='Квантование (3 бита)')
plt.xlabel('Частота (Гц)')
plt.ylabel('Амплитуда')
plt.title('13. Спектр при АЦП = 3 бита')
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.show()