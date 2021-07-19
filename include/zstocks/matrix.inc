
#if defined _matrix_included
 #endinput
#endif
#define _matrix_included

// Ported from "http://www.3dkingdoms.com/weekly/matrix.h" by .#Zipcore

stock void Matrix_Identity(float mf[16])
{
	mf[0] = 1.0; mf[1] = 0.0; mf[2] = 0.0; mf[3] = 0.0;
	mf[4] = 0.0; mf[5] = 1.0; mf[6] = 0.0; mf[7] = 0.0;
	mf[8] = 0.0; mf[9] = 0.0; mf[10] = 1.0; mf[11] = 0.0;
	mf[12] = 0.0; mf[13] = 0.0; mf[14] = 0.0; mf[15] = 1.0;
}

// Concatenate 2 matrices with the * operator
stock float[16] Matrix_Concatenate(float mf[16], float inmf[16])
{
	float rmf[16];
	for (int i=0;i<16;i+=4)
	{
		for (int j=0;j<4;j++)
		{
			rmf[i + j] = mf[i + 0] * inmf[0 + j] + mf[i + 1] * inmf[4 + j] + mf[i + 2] * inmf[8 + j] + mf[i + 3] * inmf[12 + j];
		}
	}
	return rmf;
}

// Use a matrix to transform a 3D point with the * operator
stock float[3] Matrix_TransformPoint(float mf[16], float point[3])
{
	float out[3];
	out[0] = point[0] * mf[0] + point[1] * mf[4] + point[2] * mf[8] + mf[12];
	out[1] = point[0] * mf[1] + point[1] * mf[5] + point[2] * mf[9] + mf[13];
	out[2] = point[0] * mf[2] + point[1] * mf[6] + point[2] * mf[10] + mf[14];
	return out;
}

// Rotate the mf matrix fDegrees counter-clockwise around a single axis( either x, y, or z )
stock void Matrix_Rotate(float mf[16], float fDegrees, int x, int y, int z )
{
	float tmf[16];
	if (x == 1)
		Matrix_RotX(tmf, -fDegrees);
	if (y == 1)
		Matrix_RotY(tmf, -fDegrees);
	if (z == 1)
		Matrix_RotZ(tmf, -fDegrees);
	
	for (int i = 0; i < 16; i++)
		mf[i] = tmf[i] * mf[i];
}

stock void Matrix_Scale(float mf[16], float sx, float sy, float sz)
{
	int x;
	for (x = 0; x <  4; x++) 
		mf[x] *= sx;
	for (x = 4; x <  8; x++) 
		mf[x] *= sy;
	for (x = 8; x < 12; x++) 
		mf[x] *= sz;
}

stock void Matrix_Translate(float mf[16], float test[3])
{
	for (int j = 0; j < 4; j++)
		mf[12+j] += test[0] * mf[j] + test[1] * mf[4+j] + test[2] * mf[8+j]; 
}

stock float[3] Matrix_GetTranslate(float mf[16])
{
	float trn[3];
	trn[0] = mf[12];
	trn[1] = mf[13];
	trn[2] = mf[14];
	return trn;
}

stock float[3] Matrix_RotByMatrix(float norm[3], float mf[16])
{
	float out[3];
	out[0] = norm[0] * mf[0] + norm[1] * mf[4] + norm[2] * mf[8];
	out[1] = norm[0] * mf[1] + norm[1] * mf[5] + norm[2] * mf[9];
	out[2] = norm[0] * mf[2] + norm[1] * mf[6] + norm[2] * mf[10];
	return out;
}

// Zero out the translation part of the matrix
stock float[16] Matrix_RotationOnly(float mf[16])
{
	float tmf[16];
	
	for (int i = 0; i < 16; i++)
		tmf[i] = mf[i];
	
	tmf[12] = 0.0;
	tmf[13] = 0.0;
	tmf[14] = 0.0;
	return tmf;
}

// Create a rotation matrix for a counter-clockwise rotation of fDegrees around an arbitrary axis(x, y, z)
stock void Matrix_RotateMatrix(float[16] mf, float fDegrees, float x, float y, float z)
{
	Matrix_Identity(mf);
	
	float cosA = Cosine(DegToRad(fDegrees));
	float sinA = Sine(DegToRad(fDegrees));
	float m = 1.0 - cosA;
	mf[0] = cosA + x * x * m;
	mf[5] = cosA + y * y * m;
	mf[10] = cosA + z * z * m;

	float tmp1 = x * y * m;
	float tmp2 = z * sinA;
	mf[4] = tmp1 + tmp2;
	mf[1] = tmp1 - tmp2;

	tmp1 = x * z * m;
	tmp2 = y * sinA;
	mf[8] = tmp1 - tmp2;
	mf[2] = tmp1 + tmp2;

	tmp1 = y * z * m;
	tmp2 = x * sinA;
	mf[9] = tmp1 + tmp2;
	mf[6] = tmp1 - tmp2;
}

// Simple but not robust matrix inversion. (Doesn't work properly if there is a scaling or skewing transformation.)
stock float[16] Matrix_InvertSimple(float mf[16])
{
	float rmf[16];
	
	rmf[0] = mf[0]; rmf[1] = mf[4]; rmf[2] = mf[8]; rmf[3] = 0.0;
	rmf[4] = mf[1]; rmf[5] = mf[5]; rmf[6] = mf[9]; rmf[7] = 0.0;
	rmf[8] = mf[2]; rmf[9] = mf[6]; rmf[10] = mf[10]; rmf[11] = 0.0;
	
	rmf[12] = -(mf[12] * mf[0]) - (mf[13] * mf[1]) - (mf[14] * mf[2]);
	rmf[13] = -(mf[12] * mf[4]) - (mf[13] * mf[5]) - (mf[14] * mf[6]);
	rmf[14] = -(mf[12] * mf[8]) - (mf[13] * mf[9]) - (mf[14] * mf[10]);
	
	rmf[15] = 1.0;
	
	return rmf;
}

stock float[16] Matrix_InvertRot(float mf[16])
{
	float rmf[16];
	
	rmf[0] = mf[0]; rmf[1] = mf[4]; rmf[2] = mf[8]; rmf[3] = 0.0;
	rmf[4] = mf[1]; rmf[5] = mf[5]; rmf[6] = mf[9]; rmf[7] = 0.0;
	rmf[8] = mf[2]; rmf[9] = mf[6]; rmf[10] = mf[10]; rmf[11] = 0.0;
	rmf[12] = 0.0; rmf[13] = 0.0; rmf[14] = 0.0; rmf[15] = 1.0;
	
	return rmf;
}

// helpers for Rotate

stock void Matrix_RotX(float mf[16], float angle)
{ 
	mf[5] = Cosine(DegToRad(angle));
	mf[6] = Sine(DegToRad(angle));
	mf[9] = -Sine(DegToRad(angle));
	mf[10] = Cosine(DegToRad(angle));
}

stock void Matrix_RotY(float mf[16], float angle)
{
	mf[0] = Cosine(DegToRad(angle));
	mf[2] = -Sine(DegToRad(angle));
	mf[8] = Sine(DegToRad(angle));
	mf[10] = Cosine(DegToRad(angle));
}

stock void Matrix_RotZ(float mf[16], float angle)
{
	mf[0] = Cosine(DegToRad(angle));
	mf[1] = Sine(DegToRad(angle));
	mf[4] = -Sine(DegToRad(angle));
	mf[5] = Cosine(DegToRad(angle));
}