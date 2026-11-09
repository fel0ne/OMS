#include<iostream>
#include<cmath>

#include <iomanip>
#define N 5

void shift_r(int n, bool x[],int first_n){
    bool temp[n];
    
    for (int i = 0;i < n-1; i++){
        temp[i+1] = x[i];
    }
    if(first_n == -1){
        temp[0] = x[n-1];
    }
    else{
        temp[0] = first_n;
    }

    for(int i = 0; i < n; i++){
        x[i] = temp[i];
    }
}

void print_array(int n, bool x[]){
    for(int i = 0; i <  n; i++){
        std::cout << x[i] << " ";
    }
    std::cout << std::endl;
}


bool gold_cycle(bool x[N], bool y[N]){
    bool out = x[N-1] ^ y[N-1];
    int x_xor_result = x[N-2] ^ x[N-1];
    int y_xor_result = y[1] ^ y[N-1];

    shift_r(N,x,x_xor_result);
    shift_r(N,y,y_xor_result);

    return out;
}

double calc_autocorr(int n, bool orig[],bool shifted[]) {
    int matches = 0;
    int mismatches = 0;
    double result;
    for (int i = 0; i < n; ++i) {
        if (orig[i] == shifted[i]) {
            matches++;
        } else {
            mismatches++;
        }
    }
    result = static_cast<double>(matches - mismatches) / n;
    return result;
}

void autocor_table(int len_gold,bool gold[]){
    bool shifted_gold[len_gold];
    for(int i = 0; i <len_gold; i++){
        shifted_gold[i] = gold[i];
    }


    std::cout << "Сдвиг\tПоследовательность (31 бит)\tАвтокорреляция\n";
    for (int shift = 0; shift <= len_gold; ++shift) {
        double r = calc_autocorr(len_gold, gold, shifted_gold);

        std::cout << std::setw(2) << shift << "\t";
        for (int b : shifted_gold) std::cout << b;
        std::cout << "\t" << std::fixed << std::setprecision(8) << r << "\n";

        shift_r(len_gold,shifted_gold,-1);
    }
}
int main(){
    bool x[N] = {0,0,1,0,1};
    bool y[N] = {0,1,1,0,0};
    int len_gold = std::pow(2,N) -1; 
    bool gold[len_gold];
    for(int i = 0; i < len_gold; i++){
        gold[i] = gold_cycle(x,y);
    }
    std::cout << "x = ";    
    print_array(N,x);
    std::cout << "y = ";
    print_array(N,y);
    std::cout << "gold = ";
    print_array(len_gold,gold);
    std::cout << std::endl << std::endl << std::endl;
    autocor_table(len_gold,gold);


    bool x2[N] = {0, 0, 1, 1, 0}; // 6
    bool y2[N] = {0, 0, 1, 1, 1}; // 7
    bool gold2[len_gold];
    for (int i = 0; i < len_gold; i++) {
        gold2[i] = gold_cycle(x2, y2);
    }
    
    std::cout << std::endl << std::endl << std::endl;
    std::cout << "x2 = ";    
    print_array(N,x2);
    std::cout << "y2 = ";
    print_array(N,y2);
    std::cout << "Gold 2: ";
    print_array(len_gold, gold2);
    std::cout << "\n";

    std::cout << std::endl << std::endl << std::endl;
    autocor_table(len_gold,gold2);

    // --- Пункт 4: Взаимная корреляция ---
    double cross_corr = calc_autocorr(len_gold, gold, gold2);
    std::cout << "Взаимная корреляция Gold1 и Gold2  " 
              << std::fixed << std::setprecision(5) << cross_corr << std::endl;

}
