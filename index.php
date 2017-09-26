<?php
    if (!mkdir('./test/test', 0777, true)) {
        die('Failed to create folders...');
    }
    phpinfo();
?>