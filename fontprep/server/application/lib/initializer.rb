# Global Variables
FONTPREP_SECRET = ''

APPLICATION_SUPPORT_PATH    = File.join(File.expand_path('~'), "Library", "Application Support", "FontPrep")
DESKTOP_PATH                = File.join(File.expand_path('~'), "Desktop")
TRASH_PATH                  = File.join(File.expand_path('~'), ".Trash")
SYSTEM_FONT_PATH            = File.join( "/", "Library", "Fonts")
GENERATED_PATH              = File.join(APPLICATION_SUPPORT_PATH, 'generated')
DATABASE_PATH               = File.join(APPLICATION_SUPPORT_PATH, 'db', 'db.yaml')
DATABASE_DIR                = File.join(APPLICATION_SUPPORT_PATH, 'db')

FUSION_PATH                 = File.join('external', 'bin', 'fontforge')
TITO_PATH                   = File.join('external', 'bin', 'ttf2eot')
PYTHON_PATH                 = File.join('/', 'usr', 'bin', 'python')

AUTOHINT_SCRIPT_PATH        = File.join('external', 'scripts', 'autohint')
NORMALIZE_NAMES_SCRIPT_PATH = File.join('external', 'scripts', 'normalize-names')
CONVERT_SCRIPT_PATH         = File.join('external', 'scripts', 'convert')
CHARS_SCRIPT_PATH           = File.join('external', 'scripts', 'chars')
FAMILY_SCRIPT_PATH          = File.join('external', 'scripts', 'family')
WEBFONT_SCRIPT_PATH         = File.join('external', 'scripts', 'webfont.pe')
NAME_SCRIPT_PATH            = File.join('external', 'scripts', 'name')
SVGS_SCRIPT_PATH            = File.join('external', 'scripts', 'svgs')
SUBSET_SCRIPT_PATH          = File.join('external', 'scripts', 'subset')
VEND_SCRIPT_PATH            = File.join('external', 'scripts', 'vend')
EOT_LITE_PATH               = File.join('external', 'scripts', 'eotlitetool.py')

FONT_EXPORT_TEMPLATE_PATH   = File.join('external', 'font_export_template.css')
FONT_EXPORT_PREVIEW_PATH    = File.join('external', 'preview_template.html')

MAX_VIEWABLE_CHARS        = 500

FP_BLACKLIST = [
  'ADBE',
  'AEF',
  'AUTO',
  'BOLD',
  'COMM',
  'DELV',
  'DINR',
  'EMT',
  'EMGR',
  'FBI',
  'FSI',
  'FSMI',
  'FTFT',
  'H&FJ',
  'HOUS',
  'ITFO',
  'JPTT',
  'JRD',
  'KBNT',
  'KLIM',
  'KLTF',
  'KNTR',
  'LFS',
  'LNTO',
  'LUSH',
  'MLSS',
  'MONO',
  'OKAY',
  'PGR',
  'PTF',
  'PRTF',
  'PROD',
  'SCTO',
  'SUDT',
  'TERM',
  'TJS',
  'TPTQ',
  'TYCU',
  'VLLG',
  'XLJB'
]

