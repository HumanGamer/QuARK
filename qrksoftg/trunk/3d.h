#ifndef H_3d
#define H_3d

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned char      FxU8;
typedef   signed char      FxI8;
typedef unsigned short int FxU16;
typedef   signed short int FxI16;
typedef unsigned long int  FxU32;
typedef   signed long int  FxI32;
typedef          long int  FxBool;


typedef FxU32 GrColor_t;
typedef FxU8  GrAlpha_t;
typedef FxI32 GrChipID_t;
typedef FxI32 GrCombineFunction_t;
typedef FxI32 GrColorCombineFunction_t;
typedef FxI32 GrAspectRatio_t;
//typedef FxU8  GrFog_t;
//typedef FxI32 GrFogMode_t;
typedef FxI32 GrColorFormat_t;
typedef FxI32 GrOriginLocation_t;
typedef FxI32 GrLOD_t;
typedef FxI32 GrTextureFormat_t;
typedef FxU32 GrTexTable_t;
typedef FxU32 GrHint_t;
typedef FxU32 GrScreenResolution_t;
typedef FxU32 GrScreenRefresh_t;


typedef struct { //__declspec(align(4))?
	GrLOD_t smallLod, largeLod;
	GrAspectRatio_t aspectRatio;
	GrTextureFormat_t format;
	void *data;
} GrTexInfo;

typedef struct { //__declspec(align(4))?
	float sow, tow, oow;
} GrTmuVertex;

typedef struct { //__declspec(align(4))?
	float x, y, z;
	float r, g, b;
	float ooz;
	float a;
	float oow;
	GrTmuVertex tmuvtx[2];
} GrVertex;


#define EPSILON          (1.0/64)
#define MINWBITS         6
#define MINW             (1<<MINWBITS)
#define MAXW             (65535-128)
#define OOWTABLEBITS     16
#define OOWTABLESIZE     (1<<OOWTABLEBITS)
#define OOWTABLEBASE     (OOWTABLESIZE<<MINWBITS)
#define MAXOOWBIAS       (unsigned int)(OOWTABLEBASE/(float)MAXW)

// --- Glide ---

//#define GR_FOG_TABLE_SIZE      64

//GrTextureFormat_t
#define GR_TEXFMT_RGB_565  10
#define GR_TEXFMT_RGB_443  222    // custom internal format; 11-bits (see RGBBITS)

//GrFogMode_t
//#define GR_FOG_DISABLE     0
//#define GR_FOG_WITH_TABLE  2

//GrHint_t
#define GR_HINT_STWHINT  0

//GrSTWHint_t
#define GR_STWHINT_W_DIFF_TMU0  2

void __declspec(dllexport) __stdcall grTexSource(GrChipID_t tmu, FxU32 startAddress, FxU32 evenOdd, GrTexInfo *info);
void __declspec(dllexport) __stdcall softgLoadFrameBuffer(int *buffer, int format);
void __declspec(dllexport) __stdcall grDrawTriangle(const GrVertex *a, const GrVertex *b, const GrVertex *c);
void __declspec(dllexport) __stdcall grBufferClear(GrColor_t color, GrAlpha_t alpha, FxU16 depth);
void __declspec(dllexport) __stdcall grTexDownloadTable(GrChipID_t tmu, GrTexTable_t type, void *data);
void __declspec(dllexport) __stdcall grGlideInit(void);
void __declspec(dllexport) __stdcall grClipWindow(FxU32 minx, FxU32 miny, FxU32 maxx, FxU32 maxy);
FxBool __declspec(dllexport) __stdcall grSstWinOpen(FxU32 hwnd, GrScreenResolution_t res, GrScreenRefresh_t ref, GrColorFormat_t cformat, GrOriginLocation_t org_loc, int num_buffers, int num_aux_buffers);
void __declspec(dllexport) __stdcall grSstWinClose(void);
int  __declspec(dllexport) __stdcall softgQuArK(void);
void __declspec(dllexport) __stdcall grConstantColorValue(GrColor_t color);
//void __declspec(dllexport) __stdcall grFogMode(GrFogMode_t mode);
//void __declspec(dllexport) __stdcall grFogColorValue(GrColor_t color);
//void __declspec(dllexport) __stdcall guFogGenerateExp2(GrFogTable_t *fogtable, float density);
void __declspec(dllexport) __stdcall guColorCombineFunction(GrColorCombineFunction_t func);
void __declspec(dllexport) __stdcall grHints(GrHint_t type, FxU32 hintMask);

#ifdef __cplusplus
}
#endif

#endif //H_3d
