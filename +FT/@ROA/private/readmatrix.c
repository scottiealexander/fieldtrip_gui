/*=============================================================================
readmatrix.c

Description: reads binary data element-by-element into a double matrix

Syntax: x = readmatrix(path_file,idx,bytes)

In:
	path_file - the path to a binary file as a string
	idx       - a N-length vector of indicies to read
	bytes     - the number of bytes-per-element of the datatype contained in
				path_file
Out:
	x - a N-length vector of doubles

Updated: 2014-04-21
Scottie Alexander

Please send bug reports to: scottiealexander11@gmail.com
=============================================================================*/
#include "mex.h"
#include <stdio.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

char *buf;
FILE *fid;
mwSize buflen;
size_t nrow, nbyte, siz;
long int k, kread;
long int fsize, kcur;
double *ary, *idx;

if (nrhs < 3) {	
	mexErrMsgTxt("ERROR: Not enough input arguemnts!");
}

buflen = mxGetNumberOfElements(prhs[0])+1;
buf = mxCalloc(buflen,sizeof(char));
if (mxGetString(prhs[0],buf,buflen) != 0) {	
	mexErrMsgTxt("ERROR: extracting string from prhs[0]");
}

fid = fopen(buf,"rb");
if (fid == NULL) {	
	mexErrMsgTxt("ERROR: Could not open file!");
}

fseek(fid, 0, SEEK_END);
fsize = ftell(fid);
rewind(fid);

idx = mxGetPr(prhs[1]);
nrow = mxGetNumberOfElements(prhs[1]);
nbyte = (size_t) mxGetScalar(prhs[2]);

if (nbyte < 1) {	
	mexErrMsgTxt("ERROR: bytes arguement cannot be < 1!");
}

plhs[0] = mxCreateDoubleMatrix(nrow, 1, mxREAL);
ary = mxGetPr(plhs[0]);

for(k = 0; k < nrow; ++k) {
	kcur = (long int) idx[k];	
	kread = (kcur - 1)*nbyte;	
	if (kread < fsize) {
	 	fseek(fid, kread, SEEK_SET);
 		siz = fread(ary+k, nbyte, 1, fid);
	} else {
		mexPrintf("ERROR: index [%d] exceedes matrix dimentions!\n",kcur);
		mexErrMsgTxt("See above...");
	}
}
fclose(fid);
mxFree(buf);
}
