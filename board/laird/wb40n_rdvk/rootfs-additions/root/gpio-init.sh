#!/bin/sh

echo 24 > /sys/class/gpio/export 
echo out > /sys/class/gpio/pioA24/direction 
echo 0 > /sys/class/gpio/pioA24/value
