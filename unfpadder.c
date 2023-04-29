#include <iostream>
#include <cstdint>
#include <bitset>
#include <fenv.h>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <random>
#include <ctime>
#pragma STDC FENV_ACCESS ON
// bad practice I dont care here
using namespace std;
union U {
    uint32_t n;
    float f;
};
struct fp {
    U u;
    fp(){
        u.n = 0;
    };
    fp(uint32_t a){
        u.n = a;
    };     
    fp(float a){
        u.f = a;
    };
    uint32_t sign() {
        return u.n >> 31;
    }    
    uint32_t exponent() {
        return (u.n >> 23) & 0x00ff;
    }
    uint32_t mantissa32() { 
        return u.n & 0x007fffff;
    }
    uint32_t mantissa16() {
        return (u.n & 0x007fffff) >> 16;
    }
    float& get_float() {
        return u.f;
    }
    uint32_t get_uint32_t() {
        return u.n;
    }
    uint16_t get_uint16_t() {
        return u.n >> 16;
    }
    void mask_to_bfloat16(){
        u.n = u.n & 0xffff0000;
    }
};
void print_fp(fp u){
    uint32_t sign = u.sign();
    uint32_t exponent = u.exponent();
    uint32_t mantissa32 = u.mantissa32();
    uint32_t mantissa16 = u.mantissa16();
    cout << u.get_float() << endl;
    cout << hex << "HEX Sign: " << sign << " exponent: " << exponent << " mantissa32: " << mantissa32 << " mantissa16: " << mantissa16 << endl;
    cout << "BINARY Sign: " << bitset<1>{sign} << " exponent: " << bitset<8>{exponent} << " mantissa32: " << bitset<23>{mantissa32} << " mantissa16: " << bitset<7>{mantissa16} << endl;
    cout << dec << "DEC Sign: " << sign << " exponent: " << exponent << " mantissa32: " << mantissa32 << " mantissa16: " << mantissa16 << endl;
    cout << hex << "0x" << u.get_uint32_t() << endl;
}

fp fpadder32_truncation(fp u1, fp u2){
    const int originalRounding = fegetround( );
    fesetround(FE_TOWARDZERO);
    fp u3;
    float result = u1.get_float() + u2.get_float();
    u3 = fp(result);
    fesetround(originalRounding);
    return u3;
}
fp fpadder32_truncation_unsigned(fp &u1, fp &u2){
    if (rand() % 2 == 1){
        u1.get_float() = u1.get_float();
        u2.get_float() = u2.get_float();
    } else {
        u1.get_float() = -u1.get_float();
        u2.get_float() = -u2.get_float();
    }
    const int originalRounding = fegetround( );
    fesetround(FE_TOWARDZERO);

    fp u3;
    float result = u1.get_float() + u2.get_float();
    u3 = fp(result);
    fesetround(originalRounding);
    return u3;
}

fp rand_float_gen(){
    fp u3;
    std::random_device rd;  //Will be used to obtain a seed for the random number engine
    std::mt19937 gen(rd()); //Standard mersenne_twister_engine seeded with rd()
    // possibility of generate an edge case is 0.25
    std::bernoulli_distribution d(0.25);
    // a normal distribution float num generator
    std::normal_distribution<> dd{0,1};
#ifdef UNSIGNED
    float r = abs(dd(gen));
#else
    float r = dd(gen);
#endif
    // 0, inf, nan, normal
    fp fp_gen[4] = {fp(float(0)), fp(uint32_t(0x7f800000)), fp(uint32_t(0x7fc00000)), fp(r)};
    std::uniform_int_distribution<> distrib(0, 2);
    int index = distrib(gen);
    if(!d(gen)) {
        index = 3;
    } 
    return fp_gen[index];
}
void store_test(fp u1, fp u2, fp u3){
    ofstream test;
    test.open("saved_test", ios::out | ios::app); 
    test << hex << "h"<< u1.get_uint32_t()<< " " << "h"<< u2.get_uint32_t() << " " << "h" <<u3.get_uint32_t() << "\n";
    test.close();
}
int main() {
    srand (static_cast <unsigned> (time(0)));
    int num = 100;
    for (int i = 0; i < num; i++) {
        fp u1 = rand_float_gen();
        fp u2 = rand_float_gen();
        #ifdef UNSIGNED
            fp u3 = fpadder32_truncation_unsigned(u1, u2);
        #else
            fp u3 = fpadder32_truncation(u1, u2);
        #endif 
        store_test(u1, u2, u3);
        cout << u1.get_float() << " " << u2.get_float() << " " << u3.get_float() << "\n";
    }
    //print_fp(u3);
    return 0;
}
