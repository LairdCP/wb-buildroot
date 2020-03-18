#!/bin/sh

rm /lib/firmware/ath6k/AR6004/hw3.0/bdata.bin
rm /lib/firmware/ath6k/AR6004/hw3.0/fw-5.bin
ln -s `ls /lib/firmware/ath6k/AR6004/hw3.0/50NBT* | tail -1` /lib/firmware/ath6k/AR6004/hw3.0/bdata.bin
ln -s `ls /lib/firmware/ath6k/AR6004/hw3.0/fw_v* | tail -1` /lib/firmware/ath6k/AR6004/hw3.0/fw-5.bin
