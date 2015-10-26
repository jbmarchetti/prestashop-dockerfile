<?php
define('_DB_SERVER_', getenv("DB_SERVER"));
define('_DB_NAME_', getenv("DB_NAME"));
define('_DB_USER_', getenv("DB_USER"));
define('_DB_PASSWD_', getenv("DB_PASSWD"));
define('_DB_PREFIX_', 'ps_');
define('_MYSQL_ENGINE_', 'InnoDB');
define('_PS_CACHING_SYSTEM_', 'CacheApc');
define('_PS_CACHE_ENABLED_', '0');
define('_MEDIA_SERVER_1_', '');
define('_MEDIA_SERVER_2_', '');
define('_MEDIA_SERVER_3_', '');
define('_COOKIE_KEY_', getenv("COOKIE_KEY"));
define('_COOKIE_IV_', getenv("COOKIE_IV"));
define('_PS_CREATION_DATE_', getenv("PS_CREATION_DATE"));
define('_PS_VERSION_', getenv("PS_VERSION"));
define('_RIJNDAEL_KEY_', getenv("RIJNDAEL_KEY"));
define('_RIJNDAEL_IV_', getenv("RIJNDAEL_IV"));
?>
