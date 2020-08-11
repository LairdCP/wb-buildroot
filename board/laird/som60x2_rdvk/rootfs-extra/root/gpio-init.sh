echo 107 > /sys/class/gpio/export
echo out > /sys/class/gpio/pioD11/direction
echo 0 > /sys/class/gpio/pioD11/value
