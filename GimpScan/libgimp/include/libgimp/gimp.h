// An extract from gimp 2.10 headers to avoid gimplib's dependencies.

#ifndef gimp_h
#define gimp_h

typedef signed char gint8;
typedef unsigned char guint8;

typedef signed short gint16;
typedef unsigned short guint16;

typedef signed int gint32;
typedef unsigned int guint32;

typedef char   gchar;
typedef short  gshort;
typedef long   glong;
typedef int    gint;
typedef gint   gboolean;

typedef unsigned char   guchar;
typedef unsigned short  gushort;
typedef unsigned long   gulong;
typedef unsigned int    guint;

typedef float   gfloat;
typedef double  gdouble;

typedef void* gpointer;
typedef const void *gconstpointer;

typedef enum
{
  GIMP_INTERNAL,   /*< desc="Internal GIMP procedure" >*/
  GIMP_PLUGIN,     /*< desc="GIMP Plug-In" >*/
  GIMP_EXTENSION,  /*< desc="GIMP Extension" >*/
  GIMP_TEMPORARY   /*< desc="Temporary Procedure" >*/
} GimpPDBProcType;

typedef enum
{
  GIMP_PDB_INT32,
  GIMP_PDB_INT16,
  GIMP_PDB_INT8,
  GIMP_PDB_FLOAT,
  GIMP_PDB_STRING,
  GIMP_PDB_INT32ARRAY,
  GIMP_PDB_INT16ARRAY,
  GIMP_PDB_INT8ARRAY,
  GIMP_PDB_FLOATARRAY,
  GIMP_PDB_STRINGARRAY,
  GIMP_PDB_COLOR,
  GIMP_PDB_ITEM,
  GIMP_PDB_DISPLAY,
  GIMP_PDB_IMAGE,
  GIMP_PDB_LAYER,
  GIMP_PDB_CHANNEL,
  GIMP_PDB_DRAWABLE,
  GIMP_PDB_SELECTION,
  GIMP_PDB_COLORARRAY,
  GIMP_PDB_VECTORS,
  GIMP_PDB_PARASITE,
  GIMP_PDB_STATUS,
  GIMP_PDB_END,

#ifndef GIMP_DISABLE_DEPRECATED
  GIMP_PDB_PATH     = GIMP_PDB_VECTORS,     /*< skip >*/
  GIMP_PDB_BOUNDARY = GIMP_PDB_COLORARRAY,  /*< skip >*/
  GIMP_PDB_REGION   = GIMP_PDB_ITEM         /*< skip >*/
#endif /* GIMP_DISABLE_DEPRECATED */
} GimpPDBArgType;

typedef enum
{
  GIMP_RUN_INTERACTIVE,     /*< desc="Run interactively"         >*/
  GIMP_RUN_NONINTERACTIVE,  /*< desc="Run non-interactively"     >*/
  GIMP_RUN_WITH_LAST_VALS   /*< desc="Run with last used values" >*/
} GimpRunMode;

typedef enum
{
  GIMP_PDB_EXECUTION_ERROR,
  GIMP_PDB_CALLING_ERROR,
  GIMP_PDB_PASS_THROUGH,
  GIMP_PDB_SUCCESS,
  GIMP_PDB_CANCEL
} GimpPDBStatusType;

struct _GimpRGB
{
  gdouble r, g, b, a;
};
typedef struct _GimpRGB  GimpRGB;

struct _GimpParamRegion
{
  gint32 x;
  gint32 y;
  gint32 width;
  gint32 height;
};
typedef struct _GimpParamRegion GimpParamRegion;

struct _GimpParasite
{
  gchar    *name;
  guint32   flags;
  guint32   size;
  gpointer  data;
};
typedef struct _GimpParasite GimpParasite;

union _GimpParamData
{
  gint32            d_int32;
  gint16            d_int16;
  guint8            d_int8;
  gdouble           d_float;
  gchar            *d_string;
  gint32           *d_int32array;
  gint16           *d_int16array;
  guint8           *d_int8array;
  gdouble          *d_floatarray;
  gchar           **d_stringarray;
  GimpRGB          *d_colorarray;
  GimpRGB           d_color;
  GimpParamRegion   d_region; /* deprecated */
  gint32            d_display;
  gint32            d_image;
  gint32            d_item;
  gint32            d_layer;
  gint32            d_layer_mask;
  gint32            d_channel;
  gint32            d_drawable;
  gint32            d_selection;
  gint32            d_boundary;
  gint32            d_path; /* deprecated */
  gint32            d_vectors;
  gint32            d_unit;
  GimpParasite      d_parasite;
  gint32            d_tattoo;
  GimpPDBStatusType d_status;
};
typedef union  _GimpParamData   GimpParamData;


struct _GimpParam
{
  GimpPDBArgType type;
  GimpParamData  data;
};
typedef struct _GimpParam       GimpParam;


typedef void (* GimpInitProc)  (void);
typedef void (* GimpQuitProc)  (void);
typedef void (* GimpQueryProc) (void);
typedef void (* GimpRunProc)   (const gchar      *name,
                                gint              n_params,
                                const GimpParam  *param,
                                gint             *n_return_vals,
                                GimpParam       **return_vals);

struct _GimpPlugInInfo
{
  GimpInitProc  init_proc;
  GimpQuitProc  quit_proc;
  GimpQueryProc query_proc;
  GimpRunProc   run_proc;
};
typedef struct _GimpPlugInInfo  GimpPlugInInfo;

struct _GimpParamDef
{
  GimpPDBArgType  type;
  gchar          *name;
  gchar          *description;
};
typedef struct _GimpParamDef    GimpParamDef;


/* The main procedure that must be called with the PLUG_IN_INFO structure
 * and the 'argc' and 'argv' that are passed to "main".
 */
gint           gimp_main                (const GimpPlugInInfo *info,
                                         gint                  argc,
                                         gchar                *argv[]);

/* Forcefully causes the gimp library to exit and
 *  close down its connection to main gimp application.
 */
void           gimp_quit                (void);



/* Install a procedure in the procedure database.
 */
void           gimp_install_procedure   (const gchar        *name,
                                         const gchar        *blurb,
                                         const gchar        *help,
                                         const gchar        *author,
                                         const gchar        *copyright,
                                         const gchar        *date,
                                         const gchar        *menu_label,
                                         const gchar        *image_types,
                                         GimpPDBProcType     type,
                                         gint                n_params,
                                         gint                n_return_vals,
                                         const GimpParamDef *params,
                                         const GimpParamDef *return_vals);


gint          gimp_getpid               (void);

gint32        gimp_file_load            (GimpRunMode  run_mode,
                                         const gchar *filename,
                                         const gchar *raw_filename);

gint32        gimp_display_new          (gint32 image_ID);

gboolean      gimp_image_set_filename   (gint32       image_ID,
                                         const gchar *filename);

#endif /* gimp_h */
