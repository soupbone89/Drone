#!/usr/bin/python3
from sys import path; path.append("/opt/pyMultiWii/")
from time import sleep
from threading import Thread
from pymultiwii import MultiWii

board = MultiWii("/dev/ttyS2")
roll=1500
pitch=1500
throttle=988
yaw=1500
aux1=1000
aux2=1500
aux3=1500
aux4=1500

def arm():
  global aux1
  aux1 = 2000
  
def disarm():
  global aux1
  aux1 = 1000
  
def send():
  INTERVAL = 0.01
  while True:
    board.sendCMD(16, MultiWii.SET_RAW_RC, [roll,pitch,throttle,
yaw,aux1,aux2,aux3,aux4])
    sleep(INTERVAL)

main = Thread(target=send, args=())
main.start()
do_something()
main.join()
