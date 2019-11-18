#!/bin/sh -x

if [ -e ${TARGET_DIR}/etc/init.d/S90nodm ]; then
    rm ${TARGET_DIR}/etc/init.d/S40xorg
fi

# Add a few consoles on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab && \
	sed -i 's/^tty1::.*# GENERIC_SERIAL$/tty1::respawn:\/sbin\/getty -L  tty1 0 vt100 # display console\
tty2::respawn:\/sbin\/getty -L  tty2 0 vt100 # display console\
tty3::respawn:\/sbin\/getty -L  tty3 0 vt100 # display console\
tty4::respawn:\/sbin\/getty -L  tty4 0 vt100 # display console\
tty5::respawn:\/sbin\/getty -L  tty5 0 vt100 # display console\
tty6::respawn:\/sbin\/getty -L  tty6 0 vt100 # display console/' ${TARGET_DIR}/etc/inittab
fi
