#! /bin/sh

touch /tmp/zero.txt #creamos un archivo de texto vacio
./tp0 -a encode -i /tmp/zero.txt -o /tmp/zero.txt.b64
ls -l /tmp/zero.txt.b64
#-rw-r--r-- 1 user group 0 2018-09-08 16:21 /tmp/zero.txt.b64

echo -n M | ./tp0 #codificamos caracter ASCII M
#TQ==
echo

echo -n Ma | ./tp0 #codificamos caracter ASCII M y a
#TWE=
echo



echo -n "Man" | ./tp0 #codificamos Man
#TWFu
echo
echo Man | ./tp0 | ./tp0 -a decode #codificamos y decodificamos
#Man
echo
echo xyz | ./tp0 | ./tp0 -a decode | od -t c #verificamos bit a bit
#0000000 x y z \n
#0000004
echo
yes | head -c 1024 | ./tp0 -a encode #codificamos 1024 bytes, comprobamos longitud
#eQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkK
#...
#eQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5CnkKeQp5Cg==
echo

yes | head -c 1024 | ./tp0 -a encode | ./tp0 -a decode | wc -c #verificamos que los bytes sean 1024
#1024
echo

#Generamos archivos de tamaño creciente
#cat /dev/zero | ./tp0 -a encode

n=1;
while :; do

head -c $n </dev/urandom >/tmp/in.bin;

./tp0 -a encode -i /tmp/in.bin -o /tmp/out.b64;

./tp0 -a decode -i /tmp/out.b64 -o /tmp/out.bin;

if diff /tmp/in.bin /tmp/out.bin; then :; else

echo ERROR: $n;

break;

fi

echo ok: $n;

n=$(($n+1));

rm -f /tmp/in.bin /tmp/out.b64 /tmp/out.bin
done