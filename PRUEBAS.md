# Informe de pruebas

## Modificación 1: servidor Alpine para copias de seguridad de MariaDB mediante NFS

Qué demuestra: ServidorDb guarda las copias de MariaDB en el almacenamiento NFS de ServidorAlmacenamiento y una copia permite recuperar los datos.

### 1.1. Se genera una copia de seguridad en el almacenamiento NFS

* Dónde: en mi equipo, desde el directorio `ansible/`.
* Orden:

```bash
# Insertar un registro
ansible bd -b -m shell -a "mariadb guestbook -e \"INSERT INTO guestbook (name,message) VALUES ('Prueba NFS','Registro de prueba para restauración');\""

# Ejecución manual de la copia
ansible bd -b -m shell -a "/usr/local/sbin/backup-mariadb.sh"

# Comprobar que se ha generado
ansible bd -b -m shell -a "ls -lh /mnt/mariadb-backups/guestbook-*.sql.gz | tail -n 1"
```

* Resultado esperado: la orden termina correctamente, aparece el mensaje `Copia de seguridad creada: /mnt/mariadb-backups/guestbook-<fecha>.sql.gz` y `ls` muestra el fichero comprimido dentro de `/mnt/mariadb-backups/`.

Salida obtenida:

```text
❯ ansible bd -b -m shell -a "mariadb guestbook -e \"INSERT INTO guestbook (name,message) VALUES ('Prueba NFS','Registro de prueba para restauración');\""
bd | CHANGED | rc=0 >>

❯ ansible bd -b -m shell -a "/usr/local/sbin/backup-mariadb.sh"
bd | CHANGED | rc=0 >>
Copia de seguridad creada: /mnt/mariadb-backups/guestbook-20261126-234958.sql.gz

❯ ansible bd -b -m shell -a "ls -lh /mnt/mariadb-backups/guestbook-*.sql.gz | tail -n 1"
bd | CHANGED | rc=0 >>
-rw-------+ 1 nobody nogroup 947 Nov 26 23:49 /mnt/mariadb-backups/guestbook-20261126-234958.sql.gz
```

### 1.2. Se restaura la copia y se recupera el registro guardado

* Dónde: en mi equipo, desde el directorio `ansible/`.
* Nota: esta comprobación elimina y vuelve a crear la base de datos `guestbook` antes de restaurarla. Se ejecuta sobre el escenario recién desplegado, después de la comprobación 1.1 y antes de introducir datos que se quieran conservar.
* Orden:

```bash
# Localizar la última copia de seguridad
F=$(ansible bd -b -m shell -a "ls -1t /mnt/mariadb-backups/guestbook-*.sql.gz | head -n 1" | grep '/mnt/mariadb-backups/')

# Eliminar y volver a crear la base de datos
ansible bd -b -m shell -a "mariadb -e 'DROP DATABASE IF EXISTS guestbook; CREATE DATABASE guestbook CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"

# Restaurar la copia de seguridad
ansible bd -b -m shell -a "bash -o pipefail -c 'gzip -dc \"$F\" | mariadb guestbook'"

# Comprobar que el registro se ha recuperado
ansible bd -b -m shell -a "mariadb -N -e \"SELECT name, message FROM guestbook.guestbook WHERE name = 'Prueba NFS' AND message = 'Registro de prueba para restauración';\""

# Eliminar el registro de prueba
ansible bd -b -m shell -a "mariadb guestbook -e \"DELETE FROM guestbook WHERE name = 'Prueba NFS' AND message = 'Registro de prueba para restauración';\""
```

* Resultado esperado: la consulta muestra la fila `Prueba NFS    Registro de prueba para restauración`. Al terminar, se elimina el registro de prueba.

Salida obtenida:

```text
❯ F=$(ansible bd -b -m shell -a "ls -1t /mnt/mariadb-backups/guestbook-*.sql.gz | head -n 1" | grep '/mnt/mariadb-backups/')

❯ ansible bd -b -m shell -a "mariadb -e 'DROP DATABASE IF EXISTS guestbook; CREATE DATABASE guestbook CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
bd | CHANGED | rc=0 >>

❯ ansible bd -b -m shell -a "bash -o pipefail -c 'gzip -dc \"$F\" | mariadb guestbook'"
bd | CHANGED | rc=0 >>

❯ ansible bd -b -m shell -a "mariadb -N -e \"SELECT name, message FROM guestbook.guestbook WHERE name = 'Prueba NFS' AND message = 'Registro de prueba para restauración';\""
bd | CHANGED | rc=0 >>
Prueba NFS    Registro de prueba para restauración

❯ ansible bd -b -m shell -a "mariadb guestbook -e \"DELETE FROM guestbook WHERE name = 'Prueba NFS' AND message = 'Registro de prueba para restauración';\""
bd | CHANGED | rc=0 >>
```

## Modificación 2: conexión de ServidorWeb a la red física mediante br0

Qué demuestra: ServidorWeb es accesible mediante su dirección del bridge tanto desde el equipo anfitrión como desde otro equipo de la misma red física.

### 2.1. Se accede a Guestbook desde el equipo anfitrión mediante la IP del bridge

* Dónde: en mi equipo anfitrión, desde el directorio `ansible/`.
* Orden:

```bash
# Obtener la IP de br0 de ServidorWeb
IP_BR0=$(tofu -chdir=../opentofu output -json ips_servidores | python3 -c 'import json,sys; print(json.load(sys.stdin)["br0"]["web"])')

# Mostrar la IP obtenida
echo "IP br0 de ServidorWeb: $IP_BR0"

# Comprobar el acceso al servidor web mediante el dominio
curl -sS -o /dev/null -w 'HTTP %{http_code}\n' -H 'Host: www.proyecto2asir.org' "http://${IP_BR0}/"
```

* Resultado esperado: se muestra la IP asignada a ServidorWeb en `br0` y `curl` devuelve `HTTP 200`.

Salida obtenida:

```text
❯ IP_BR0=$(tofu -chdir=../opentofu output -json ips_servidores | python3 -c 'import json,sys; print(json.load(sys.stdin)["br0"]["web"])')

❯ echo "IP br0 de ServidorWeb: $IP_BR0"
IP br0 de ServidorWeb: 192.168.1.41

❯ curl -sS -o /dev/null -w 'HTTP %{http_code}\n' -H 'Host: www.proyecto2asir.org' "http://${IP_BR0}/"
HTTP 200
```

### 2.2. Se accede a Guestbook desde otro equipo de la red física

* Dónde: en otro ordenador conectado a la misma red física, desde un terminal.
* Orden: se utiliza la IP de `br0` obtenida en la comprobación 2.1. En esta ejecución es `192.168.1.41`.

```bash
curl -sS -o /dev/null -w 'HTTP %{http_code}\n' -H 'Host: www.proyecto2asir.org' http://192.168.1.41/
```

* Resultado esperado: `curl` devuelve `HTTP 200`.

Ejemplo de cómo se vería en el otro equipo:

```text
mama@debian:~$ curl -sS -o /dev/null -w 'HTTP %{http_code}\n' -H 'Host: www.proyecto2asir.org' http://192.168.1.41/
HTTP 200
```

## Modificación 3: ServidorWeb como router de ServidorDb y ServidorAlmacenamiento

Qué demuestra: ServidorDb y ServidorAlmacenamiento no tienen conexión directa a la red NAT y utilizan ServidorWeb como puerta de enlace para acceder a Internet.

### 3.1. DB y Backup utilizan ServidorWeb como puerta de enlace

* Dónde: en mi equipo, desde el directorio `ansible/`.
* Orden:

```bash
ansible servidores -m shell -a 'echo "=== $(hostname) ==="; ip -br -4 addr; ip -4 route show default'
```

* Resultado esperado:
  - En `web` aparecen las interfaces de NAT, `br0` y la red interna, con `10.0.0.1/24` en la interfaz interna.
  - En `bd` aparece `10.0.0.2/24` en su interfaz de red y la ruta por defecto utiliza `10.0.0.1`.
  - En `backup` aparece `10.0.0.3/24` en su interfaz de red y la ruta por defecto utiliza `10.0.0.1`.

Salida obtenida:

```text
❯ ansible servidores -m shell -a 'echo "=== $(hostname) ==="; ip -br -4 addr; ip -4 route show default'
web | CHANGED | rc=0 >>
=== ServidorWeb ===
lo       UNKNOWN  127.0.0.1/8
ens3     UP       172.19.1.219/24 metric 100
ens4     UP       192.168.1.41/24 metric 100
ens5     UP       10.0.0.1/24
default via 172.19.1.1 dev ens3 proto dhcp src 172.19.1.219 metric 100
default via 192.168.1.1 dev ens4 proto dhcp src 192.168.1.41 metric 100

backup | CHANGED | rc=0 >>
=== servidor-almacenamiento ===
lo       UNKNOWN  127.0.0.1/8
ens3     UP       10.0.0.3/24
default via 10.0.0.1 dev ens3 proto static

bd | CHANGED | rc=0 >>
=== ServidorDb ===
lo       UNKNOWN  127.0.0.1/8
ens3     UP       10.0.0.2/24
default via 10.0.0.1 dev ens3 proto static
```

### 3.2. DB y Backup acceden a Internet a través de ServidorWeb

* Dónde: en mi equipo, desde el directorio `ansible/`.
* Orden:

```bash
ansible 'servidores_bd:servidores_backup' -m shell -a 'curl -4 -fsSL -o /dev/null -w "HTTP %{http_code}\n" --max-time 15 http://deb.debian.org/debian/dists/trixie/Release'
```

* Resultado esperado: tanto `bd` como `backup` devuelven `HTTP 200`. La resolución del nombre y la descarga del recurso se realizan desde las máquinas de la red interna, utilizando ServidorWeb como puerta de enlace.

Salida obtenida:

```text
❯ ansible 'servidores_bd:servidores_backup' -m shell -a 'curl -4 -fsSL -o /dev/null -w "HTTP %{http_code}\n" --max-time 15 http://deb.debian.org/debian/dists/trixie/Release'
bd | CHANGED | rc=0 >>
HTTP 200

backup | CHANGED | rc=0 >>
HTTP 200
```
