@ECHO OFF
SET src="%1"
SET dst="%~n1.gif"
php.exe convert.php %src%