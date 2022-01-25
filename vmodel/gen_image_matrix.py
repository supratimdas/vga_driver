#!/usr/bin/python3.8
# File Name     : gen_image_matrix.py
# Organization  : NONE
# Creation Date : 24-01-2022
# Last Modified : Tuesday 25 January 2022 07:13:04 PM
# Author        : Supratim Das (supratimofficio@gmail.com)
# ##########################################################

################Description#####################
#
#
#
#
#
################################################
import imageio

im = imageio.imread("NoobsCPU.png")
lines = im.shape[0]
pix_per_line = im.shape[1]

x_shift = 0 
y_shift = 0
for y in range(0,lines):
    for x in range(0,pix_per_line):
        r = im[y][x][0]
        g = im[y][x][1]
        b = im[y][x][2]
        r = 1 if r > 140 else 0
        g = 1 if g > 140 else 0
        b = 1 if b > 140 else 0

        X = x + x_shift
        Y = y + y_shift
        if(not(r & g & b)):
            print("             {9'd"+str(Y)+",10'd"+str(X)+"} : pixel_rgb = 3'b"+str(r)+str(g)+str(b)+";")
