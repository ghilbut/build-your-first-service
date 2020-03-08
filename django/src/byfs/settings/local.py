from byfs.settings.base import *


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('BYFS_LOCAL_DB_NAME', 'byfs'),
        'HOST': os.environ.get('BYFS_LOCAL_DB_HOST', '127.0.0.1'),
        'PORT': os.environ.get('BYFS_LOCAL_DB_PORT', '3306'),
        'USER': os.environ.get('BYFS_LOCAL_DB_USER', 'byfs'),
        'PASSWORD': os.environ.get('BYFS_LOCAL_DB_PASSWORD', 'byfspw'),
        'CONN_MAX_AGE': 60,
    }
}
