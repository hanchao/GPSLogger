#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Coord.h"

int casm_t1;
int casm_t2;
double casm_rr;
double casm_x1;
double casm_x2;
double casm_y1;
double casm_y2;
double casm_f;

//前置声明
unsigned int IniCasm(int a1, unsigned int a2, unsigned int a3);
long double random_yj();
long double yj_sin2(double a1);

long double Transform_yj5(double a1, double a2);
long double Transform_jyj5(double a1, double a2);
long double Transform_yjy5(double a1, double a2);
long double Transform_jy5(double a1, double a2);

//实现
unsigned int IniCasm(int a1, unsigned int a2, unsigned int a3) {
	unsigned int result; // eax@3
	long double v4; // fst7@3
	long double v5; // fst6@3

	casm_t1 = a1;
	casm_t2 = a1;
	*(double *) &casm_rr = (long double) (unsigned int) a1
		- 0.357 * (long double) (signed int) ((long double) (unsigned int) a1 / 0.357);
	if (!a1)
		casm_rr = 4599075939470750515L;
	v4 = (long double) a2;
	result = a3;
	*(double *) &casm_x1 = v4;
	v5 = (long double) a3;
	*(double *) &casm_y1 = v5;
	*(double *) &casm_x2 = v4;
	*(double *) &casm_y2 = v5;
	casm_f = 4613937818241073152L;
	return result;
}
long double random_yj() {
	long double result; // fst7@1
	long double v1; // fst7@1

	v1 = *(double *) & casm_rr * (long double) 314159269 + (long double) 453806245;
	result = 0.5 * (v1 - (long double) (2 * (signed int) (v1 * 0.5)));
	*(double *) &casm_rr = result;
	return result;
}
long double yj_sin2(double a1) {
	signed int v1; // edx@1
	long double v2; // fst7@1
	long double v3; // fst6@3
	long double v4; // fst7@4
	long double v5; // fst6@7
	long double result; // fst7@7
	long double v7; // fst5@7
	long double v8; // fst7@7

	v2 = a1;
	v1 = 0;
	if (a1 < 0.0) {
		v2 = -v2;
		v1 = 1;
	}
	v3 = v2 - 6.28318530717959 * (long double) (signed int) (v2 / 6.28318530717959);
	if (v3 <= 3.141592653589793) {
		v4 = v3;
	} else {
		v4 = v3 - 3.141592653589793;
		if (v1 == 1) {
			v1 = 0;
		} else {
			if (!v1)
				v1 = 1;
		}
	}
	v5 = v4;
	v7 = v4 * v4;
	v8 = v4 * v4 * v4;
	result = v8 * v7 * v7 * v7 * 0.00000275573192239859
		+ v8 * v7 * 0.00833333333333333
		+ v5
		- v8 * 0.166666666666667
		- v8 * v7 * v7 * 0.000198412698412698
		- v7 * v8 * v7 * v7 * v7 * 0.0000000250521083854417;
	if (v1 == 1)
		result = -result;
	return result;

}


long double Transform_yj5(double lon_offset, double lat_offset) {
	long double v2=0;
	long double v3; // fst7@1
	short v4=0; // fps@1
	char v5; // c0@1
	char v6; // c2@1
	char v7; // c3@1
	long double v8; // fst7@2
	long double v9; // fst6@3
	short v10=0; // fps@3
	char v11; // c0@3
	char v12; // c2@3
	char v13; // c3@3
	long double v14; // fst7@4
	double v16; // ST30_8@5
	double v17; // ST10_8@5
	double v18; // ST30_8@5
	double v19; // ST10_8@5
	double v20; // ST30_8@5
	double v21; // ST10_8@5

	v3 = lon_offset * lon_offset;
	// 这个是什么函数
	v2 = sqrt(v3);
	//
	v5 = v2 < v2;
	v6 = 0;
	v7 = v2 == v2;
	if ((((v4 >> 8)&0xFF)& 0x45) == 64)
		v8 = v2;
	else
		v8 = sqrt(v3);
	v9 = sqrt(v8);
	//
	v11 = v9 < v9;
	v12 = 0;
	v13 = v9 == v9;
	if ((((v10 >> 8)&0xFF) & 0x45) == 64)
		v14 = v9;
	else
		v14 = sqrt(v8);
	v16 = (double) (lat_offset * lon_offset * 0.1 + lon_offset * lon_offset * 0.1 + lat_offset + lat_offset + (double) (lon_offset + 300.0)) + (double) (v14 * 0.1);
	v17 = yj_sin2(lon_offset * 18.84955592153876) * 20.0;
	v18 = (yj_sin2(lon_offset * 6.283185307179588) * 20.0 + v17) * 0.6667 + v16;
	v19 = yj_sin2(lon_offset * 3.141592653589794) * 20.0;
	v20 = (yj_sin2(lon_offset * 1.047197551196598) * 40.0 + v19) * 0.6667 + v18;
	v21 = yj_sin2(lon_offset * 0.2617993877991495) * 150.0;
	return (yj_sin2(lon_offset * 0.1047197551196598) * 300.0 + v21) * 0.6667 + v20;

}

long double Transform_jyj5(double lat, double dlat_offset) {
	long double v2; //
	long double v3; //
	double v4; //
	double v5; //	
	//
	v4 = 0.0174532925199433 * lat;
	v5 = yj_sin2(v4) *0.00669342;
	v3 = 1.0 - yj_sin2(v4) * v5;
	v2 = sqrt(v3);
	//
	return dlat_offset * 180.0 / (6335552.7273521 / (v3 * v2) * 3.1415926);
}


long double Transform_yjy5(double lon_offset, double lat_offset) {
	long double v2; // fst5@1
	long double v3; // fst6@1
	long double v4; // fst7@1
	short v5=0; // fps@1
	char v6; // c0@1
	char v7; // c2@1
	char v8; // c3@1
	long double v9; // fst6@2
	long double v10; // fst5@3
	short v11=0; // fps@3
	char v12; // c0@3
	char v13; // c2@3
	char v14; // c3@3
	long double v15; // fst6@4
	double v17; // ST38_8@5
	double v18; // ST20_8@5
	double v19; // ST38_8@5
	double v20; // ST20_8@5
	double v21; // ST38_8@5
	double v22; // ST20_8@5
	double v23; // ST10_8@6
	double v24; // ST10_8@7

	v4 = lon_offset + lon_offset + -100.0 + lat_offset * 3.0 + lat_offset * 0.2 * lat_offset + lon_offset * 0.1 * lat_offset;
	v3 = lon_offset * lon_offset;
	v2 = sqrt(v3);
	//UNDEF(v5);
	v6 = v2 < v2;
	v7 = 0;
	v8 = v2 == v2;
	if ((((v5 >> 8)&0xff) & 0x45) == 64) {
		v9 = v2;
	} else {
		v24 = v4;
		v9 = sqrt(v3);
		v4 = v24;
	}
	v10 = sqrt(v9);
	//UNDEF(v11);
	v12 = v10 < v10;
	v13 = 0;
	v14 = v10 == v10;
	if ((((v11 >> 8)&0xff) & 0x45) == 64) {
		v15 = v10;
	} else {
		v23 = v4;
		v15 = sqrt(v9);
		v4 = v23;
	}
	v17 = v4 + v15 * 0.2;
	v18 = yj_sin2(lon_offset * 18.84955592153876) * 20.0;
	v19 = (yj_sin2(lon_offset * 6.283185307179588) * 20.0 + v18) * 0.6667 + v17;
	v20 = yj_sin2(lat_offset * 3.141592653589794) * 20.0;
	v21 = (yj_sin2(lat_offset * 1.047197551196598) * 40.0 + v20) * 0.6667 + v19;
	v22 = yj_sin2(lat_offset * 0.2617993877991495) * 160.0;
	return (yj_sin2(lat_offset * 0.1047197551196598) * 320.0 + v22) * 0.6667 + v21;
}

long double Transform_jy5(double lat, double dlon_offset) {
	long double v2; //
	long double v3; //
	long double v4; //

	v4 = yj_sin2(lat * 0.0174532925199433);
	v3 = 1.0 - yj_sin2(lat * 0.0174532925199433) *(v4 *0.00669342);
	v2 = sqrt(v3);
	//
	return (double) (dlon_offset * 180.0) / (cos(lat * 0.0174532925199433) *(6378245.0 / v2) * 3.1415926);
}

/**
* 关键函数 计算真正的偏移值
* @param a1 是否是初始化标识
* @param a2 经度
* @param a3 纬度
* @param a4 目前这个值是50
* @param a5
*/
unsigned int wgtochina_lb(int wg_flag, unsigned int wg_lng, unsigned int wg_lat, int wg_heit, int wg_week, unsigned int wg_time, unsigned int * china_lng, unsigned int * china_lat) {
	unsigned int result;

	double lat_offset;
	double v9;
	double v10;
	//
	double v12;
	double v13;
	double v14;
	double v15;
	double v16;
	double v17;
	double lat=wg_lat/3686400.0;
	double lng=wg_lng/3686400.0;
	//
	//检查坐标范围在中国范围内
	if (wg_heit <= 5000&&lng >=72.004&& lng <= 137.8347&& lat >= 0.8293&& lat <= 55.8271) 
	{
		if (wg_flag) {
			casm_t2 = wg_time;
			lat_offset = lat - 35.0;
			//
			v9 = Transform_yj5(lng - 105.0, lat_offset);
			v10 = Transform_yjy5(lng - 105.0, lat_offset);
			//
			v12 = 0.001 *wg_heit;
			//
			//
			v13 = wg_time* 0.0174532925199433;
			//
			v14 = yj_sin2(v13) + (v9 + v12);
			v15 = random_yj() + v14;
			//
			v16 = yj_sin2(v13) + (v10 + v12);
			v17 = random_yj() + v16;
			//反投影
			*china_lng= (Transform_jy5(lat, v15) + lng) * 3686400.0;
			*china_lat= (Transform_jyj5(lat, v17) + lat) * 3686400.0;
		}
		else{
			//
			IniCasm(wg_time, wg_lng, wg_lat);
			*china_lng = wg_lng;
			*china_lat= wg_lat;
		}
		result = 0;
	}else {
		(*china_lng) = 0; 
		(*china_lat) = 0;
		result = -27137;
	}
	return result;
}

int GpsCoorEncrypt(double *lLongtitude, double *lLatitude)
{
	static int wg_flag = 1;
    
	unsigned int china_lng = 0;
	unsigned int china_lat = 0;
    
	unsigned int wg_lng = (int)(*lLongtitude * 3686400);
	unsigned int wg_lat = (int)(*lLatitude * 3686400);
    
	int wg_heit = 50;
	int wg_week = 0;
	unsigned int wg_time = 0;
    
	int ret = wgtochina_lb(wg_flag, wg_lng, wg_lat, wg_heit, wg_week, wg_time, &china_lng, &china_lat);
	
	if(wg_flag==0)
	{
		wg_flag=1;
	}
    
	if(ret!=0)
	{
        return 0;
	}
    
	double lon = china_lng;
	double lat = china_lat;
    
	*lLongtitude = lon / 3686400.0;
	*lLatitude   = lat / 3686400.0;
	
	return 1;
}