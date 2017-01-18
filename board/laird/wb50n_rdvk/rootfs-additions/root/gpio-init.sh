echo 31 > /sys/class/gpio/export 
echo out > /sys/class/gpio/pioA31/direction 
echo 0 > /sys/class/gpio/pioA31/value
