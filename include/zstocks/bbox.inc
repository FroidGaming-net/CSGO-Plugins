
#if defined _bbox_included
 #endinput
#endif
#define _bbox_included

// Ported from "http://www.3dkingdoms.com/weekly/bbox.cpp" by .#Zipcore

#if !defined _zstocks_included
#include <zstocks/matrix>
#endif

stock void BBox_Set(float mf[16], float vecMins[3], float vecMaxs[3], float vecExtend[3])
{
	float test[3];
	for (int i = 0; i < 3; i++)
		test[i] = (vecMaxs[i] + vecMins[i]) * 0.5;
	Matrix_Translate(mf, test);
	
	for (int i = 0; i < 3; i++)
		vecExtend[i] = (vecMaxs[i] - vecMins[i]) / 2.0;
}

stock float[3] BBox_GetExtendSize(float extend[3])
{
	float out[3];
	for (int i = 0; i < 3; i++)
		out[i] = extend[i] * 2.0;
	
	return out;
}

stock float[3] BBox_GetCenterPoint(float mf[16])
{
	return Matrix_GetTranslate(mf);
}

// Check if a point is in this bounding box
stock bool BBox_IsPointInBox(float mf[16], float extend[3], float InP[3])
{
	// Rotate the point into the box's coordinates
	float point[3];
	point = Matrix_TransformPoint(Matrix_InvertSimple(mf), InP);
	
	// Now use an axis-aligned check
	if (FloatAbs(point[0]) < extend[0] && FloatAbs(point[1]) < extend[1] && FloatAbs(point[2]) < extend[2])
		return true;
		
	return false;
}

// Check if a sphere overlaps any part of this bounding box
stock bool BBox_IsSphereInBox(float mf[16], float extend[3], float InP[3], float fRadius)
{
	float point[3];
	point = Matrix_TransformPoint(Matrix_InvertSimple(mf), InP);
	
	float fDist;
	float fDistSq = 0.0;
	
	// Add distance squared from sphere centerpoint to box for each axis
	for (int i = 0; i < 3; i++)
	{
		if (FloatAbs(point[i]) > extend[i])
		{
			fDist = FloatAbs(point[i]) - extend[i];
			fDistSq += fDist * fDist;
		}
	}
	return (fDistSq <= fRadius * fRadius);
}

// Check if the bounding box is completely behind a plane( defined by a normal and a point )
stock bool BBox_BoxOutsidePlane(float mf[16], float extend[3], float InNorm[3], float InP[3])
{
	// Plane Normal in Box Space
	float Norm[3]; 
	Norm = Matrix_RotByMatrix(InNorm, mf); // RotByMatrix only uses rotation portion of matrix
	
	Norm[0] = FloatAbs(Norm[0]);
	Norm[1] = FloatAbs(Norm[1]);
	Norm[2] = FloatAbs(Norm[2]);
	
	float Extent = GetVectorDotProduct(Norm, extend); // Box Extent along the plane normal
	
	float PC[3];
	SubtractVectors(BBox_GetCenterPoint(mf), InP, PC);
	float Distance = GetVectorDotProduct(InNorm, PC); // Distance from Box Center to the Plane

	// If Box Centerpoint is behind the plane further than its extent, the Box is outside the plane
	if ( Distance < -Extent ) 
		return true;
	return false;
}

// Does the Line (L1, L2) intersect the Box?

stock bool BBox_IsLineInBox(float mf[16], float extend[3], float L1[3], float L2[3])
{	
	// Put line in box space
	float MInv[16];
	MInv = Matrix_InvertSimple(mf);
	
	float LB1[3];
	LB1 = Matrix_TransformPoint(MInv, L1);
	
	float LB2[3];
	LB2 = Matrix_TransformPoint(MInv, L2);

	// Get line midpoint and extent
	float LMid[3]; 
	for (int i = 0; i < 3; i++)
		LMid[i] = (LB1[i] + LB2[i]) * 0.5;
	
	float L[3];
	for (int i = 0; i < 3; i++)
		L[i] = LB1[i] - LMid[i];
	
	float LExt[3];
	for (int i = 0; i < 3; i++)
		LExt[i] = FloatAbs(L[i]);

	// Use Separating Axis Test
	// Separation vector from box center to line center is LMid, since the line is in box space
	if ( FloatAbs( LMid[0] ) > extend[0] + LExt[0] ) 
		return false;
	if ( FloatAbs( LMid[1] ) > extend[1] + LExt[1] )
		return false;
	if ( FloatAbs( LMid[2] ) > extend[2] + LExt[2] )
		return false;
	
	// Crossproducts of line and each axis
	if (FloatAbs(LMid[1] * L[2] - LMid[2] * L[1]) > (extend[1] * LExt[2] + extend[2] * LExt[1]))
		return false;
	
	if (FloatAbs(LMid[0] * L[2] - LMid[2] * L[0]) > (extend[0] * LExt[2] + extend[2] * LExt[0]))
		return false;
	
	if (FloatAbs(LMid[0] * L[1] - LMid[1] * L[0]) > (extend[0] * LExt[1] + extend[1] * LExt[0]))
		return false;
	
	// No separating axis, the line intersects
	return true;
}

// Returns a 3x3 rotation matrix as vectors
stock void BBox_GetInvRot(float mf[16], float pvRot[3][3])
{
	pvRot[0][0] = mf[0];
	pvRot[0][1] = mf[1];
	pvRot[0][2] = mf[2];
	
	pvRot[1][0] = mf[4];
	pvRot[1][1] = mf[5];
	pvRot[1][2] = mf[6];
	
	pvRot[2][0] = mf[8];
	pvRot[2][1] = mf[9];
	pvRot[2][2] = mf[10];
}

// Check if any part of a box is inside any part of another box
// Uses the separating axis test.
stock bool BBox_IsBoxInBox(float mfA[16], float mfB[16], float extendA[3], float extendB[3])
{
	float SizeA[3]; SizeA = extendA;
	float SizeB[3]; SizeB = extendB;
	
	float RotA[3][3], RotB[3][3];
	BBox_GetInvRot(mfA, RotA);
	BBox_GetInvRot(mfB, RotB);
	
	float R[3][3];  // Rotation from B to A
	float AR[3][3]; // absolute values of R matrix, to use with box extents
	float ExtentA, ExtentB, Separation;
	int i, k;
	
	// Calculate B to A rotation matrix
	for( i = 0; i < 3; i++ )
	{
		for( k = 0; k < 3; k++ )
		{
			R[i][k] = GetVectorDotProduct(RotA[i], RotB[k]);
			AR[i][k] = FloatAbs(R[i][k]);
		}
	}
            
	// Vector separating the centers of Box B and of Box A	
	float vSepWS[3];
	SubtractVectors(BBox_GetCenterPoint(mfB), BBox_GetCenterPoint(mfA), vSepWS);
	// Rotated into Box A's coordinates
	float vSepA[3];
	for( i = 0; i < 3; i++ )
		vSepA[i] = GetVectorDotProduct(vSepWS, RotA[i]);

	// Test if any of A's basis vectors separate the box
	for( i = 0; i < 3; i++ )
	{
		ExtentA = SizeA[i];
		ExtentB = GetVectorDotProduct(SizeB, AR[i]);
		Separation = FloatAbs(vSepA[i]);
	
		if (Separation > ExtentA + ExtentB)
			return false;
	}

	// Test if any of B's basis vectors separate the box
	for (i = 0; i < 3; i++)
	{
		float ARI[3];
		for (k = 0; k < 3; k++)
			ARI[k] = AR[k][i];
		
		ExtentA = GetVectorDotProduct(SizeA, ARI);
		ExtentB = SizeB[i];
		
		float RI[3];
		for (k = 0; k < 3; k++)
			RI[k] = R[k][i];
		
		Separation = FloatAbs(GetVectorDotProduct(vSepA, RI));

		if( Separation > ExtentA + ExtentB ) 
			return false;
	}

	// Now test Cross Products of each basis vector combination ( A[i], B[k] )
	for( i=0 ; i<3 ; i++ )
	{
		for( k=0 ; k<3 ; k++ )
		{
			int i1 = (i + 1) % 3, i2 = (i + 2) % 3;
			int k1 = (k + 1) % 3, k2 = (k + 2) % 3;
			ExtentA = SizeA[i1] * AR[i2][k]  +  SizeA[i2] * AR[i1][k];
			ExtentB = SizeB[k1] * AR[i][k2]  +  SizeB[k2] * AR[i][k1];
			Separation = FloatAbs( vSepA[i2] * R[i1][k]  -  vSepA[i1] * R[i2][k] );
			
			if( Separation > ExtentA + ExtentB ) 
				return false;
		}
	}

	// No separating axis found, the boxes overlap	
	return true;
}