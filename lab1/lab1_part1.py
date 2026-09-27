import numpy as np
import matplotlib.pyplot as plt
import cmath as cm
f = 4
a = 0
b = 10
t = np.linspace(a,b,(f*10+1)*(a+b))
y = np.cos(2 * np.pi * f * t + np.pi/3) + np.sin(4 * np.pi * f * t)

plt.subplot(2,2,1)
plt.plot(t,y)
plt.xlabel('t')
plt.ylabel('F(t)')

# ======= 5. PPF ======
a = [complex(0,0)]*len(t)
for x in range (len(t)):
    for n in range (len(t)):
       a[x] += y[n]*complex(np.cos(2*np.pi*x*n/len(t)),-1*np.sin(2*np.pi*x*n/len(t)))
print (a)

phi = [0]*len(t)
alpha = [0]*len(t)
for n in range (len(t)):
    phi[n] = a[n].imag
    alpha[n] = a[n].real
    

plt.subplot(2,2,2)
plt.stem(range(len(t)),phi)
plt.xlabel('idx')
plt.ylabel('phi')


plt.subplot(2,2,3)
plt.stem(range(len(t)),alpha)
plt.xlabel('idx')
plt.ylabel('alpha')
af = [complex(0,0)]*len(t)
for n in range (len(t)):
    for x in range (len(t)):
       af[n] += a[x]* complex(np.cos(2*np.pi*x*n/len(t)),np.sin(2*np.pi*x*n/len(t)))
 
    af[n] = af[n] /len(t)

opf_phi = [0]*len(t)
opf_alpha = [0]*len(t)
for n in range (len(t)):
    opf_phi[n] = af[n].imag
    opf_alpha[n] = af[n].real
plt.subplot(2,2,4)
plt.plot(t,opf_alpha)
plt.xlabel('t')
plt.ylabel('f(t)(OPF)')

plt.show()    


