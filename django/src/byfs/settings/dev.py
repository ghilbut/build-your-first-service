from byfs.settings.base import *


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ['BYFS_DEV_DB_NAME'],
        'HOST': os.environ['BYFS_DEV_DB_HOST'],
        'PORT': os.environ['BYFS_DEV_DB_PORT'],
        'USER': os.environ['BYFS_DEV_DB_USER'],
        'PASSWORD': os.environ['BYFS_DEV_DB_PASSWORD'],
        'OPTIONS': {
          'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
        },
        'CONN_MAX_AGE': 60,
    }
}
