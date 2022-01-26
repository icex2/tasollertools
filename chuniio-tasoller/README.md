## chuniio-tasoller

chuniio driver for tasoller custom 2.0 firmware

Uses WinUSB driver instead of libusb

Written in Zig (Sorry, I can't stand Windows-flavoured C++)

Downloads avaliable in [releases](https://dev.s-ul.net/akiroz/chuniio-tasoller/-/releases)

## USB Protocol

Custom firmware USB device: 1CCF:2333
- Interface 1
    - Endpoint 4 IN Interrupt (0x84)
        - data len: 36 bytes
        - data[0-2]: {0x68, 0x66, 0x84} (magic?)
        - data[3]
            - bit 0-5: beam 1-6 (1 = blocked)
            - bit 6-7: fn1 & fn2 (1 = pressed)
        - data[4-35]: touch sensor 1-32 pressure
    - Endpoint 3 OUT Bulk (0x03)
        - data len: 240 bytes
        - data[0-2]: {0x42, 0x4C, 0x00} (magic?)
        - data[3-95]: Slider LED (GRB order, right->left)
        - data[96-167]: Left LED (GRB order top->bottom)
        - data[168-239]: Right LED (GRB order bottom->top)

### Build

```
$ git clone ...
$ zig build -Drelease-fast=true
$ ls zig-out/lib/chuniio_tasoller.dll
```
