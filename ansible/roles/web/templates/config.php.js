<?php
$host = '{{ db_host }}';
$username = '{{ db_user }}';
$password = '{{ db_password }}';
$dbname = '{{ db_name }}';

$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
?>
