# Tasollertools

A collection of "tools", files and documentation for
[DJ DAO's tasoller controller](https://www.dj-dao.com/en/tasoller).

# Firmwares

## Official

### Official V1.1

[Source](https://www.dj-dao.com/en/support/10.html)

* [Distribution package](firmware/official-v1.1/TASOLLER_firmware_20210202_V1.1.zip)
* [Instructions](firmware/official-v1.1/instructions.pdf)

### Official V2.01

[Source](https://www.dj-dao.com/cn/11.html)

* [Distribution package](firmware/official-v2.01/TASOLLER_firmware_20210419_V2.01.zip)
* [Instructions](firmware/official-v2.01/instructions.pdf)

## Custom

### Custom V1.1

This firmware requires the cypress base firmware prior [V2.01](#official-v2-01) (the firmware you
have to update using the UART cable). Once you updated everything to [V2.01](#official-v2-01), this
version of the custom firmware can still be uploaded but doesn't work correctly. It will still show
the rainbox lights once the controller is powered and booted, but slider inputs are not working.

* [Distribution package](firmware/custom-v1.1/DAO.zip)
* [Instructions](firmware/custom-v1.1/readme.txt)
* [Fixed chuniio.dll](firmware/custom-v1.1/chuniio-tasoller-fixed.dll): Use this one instead of
the `chuniio.dll` provided with the distribution package. It fixes incorrect light mappings.

### Custom V2.0

This firmware requires the cypress base firmware [V2.01](#official-v2-01) (the firmware you
have to update using the UART cable).

* [Distribution package](firmware/custom-v2.0/TASOLLER_LED_FIRMWARE_V2.zip)
* Instruction: Inside distribution package

### USB chipset incompatibility

There are known issues with incompatible USB chipsets. The root-cause is currently unknown.

Once you updated to the custom firmware, either [V1.1](#custom-v1-1) or [V2.0](#custom-v2-0), the
device shows up as `I SAY NYA-O` in the device manager. However, on further inspection, it shows
that the device is not working correctly.

Potential mitigations:

* Try different USB ports on your motherboard
* Try a different motherboard/computer
* Buy a USB PCI expension card that is [known to be compatible](#known-compatible-hardware) and
connect the controller to one of the USB ports of that card

#### Known compatible hardware

* [ULANSeN 7-Port PCI-E to Type C (2), Type A (5) USB 3.0 Expansion Card with 2 Rear USB 3.0 Ports PCI Express Card](https://www.amazon.com/dp/B08H1WKQWR/ref=cm_sw_r_cp_awdb_imm_KN33ESRZD2T4G1CN8J0Q)

#### Known incompatible hardware

# Troubleshooting

## Using the custom firmware, the USB device shows as not working under device manager

See [known issue with USB chipset incompatibility](#usb-chipset-incompatibility).

# Development

## Custom firmware lsusb device information

```text
Bus 003 Device 086: ID 1ccf:2333 SkyStar I SAY NYA-O
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 
  bDeviceSubClass         0 
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x1ccf 
  idProduct          0x2333 
  bcdDevice            1.01
  iManufacturer           1 SkyStar
  iProduct                2 I SAY NYA-O
  iSerial                 3 USB Audio Gampad
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength       0x0020
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0x80
      (Bus Powered)
    MaxPower              500mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      0 
      bInterfaceProtocol      0 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x84  EP 4 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               1
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x00ff  1x 255 bytes
        bInterval               1
can't get device qualifier: Resource temporarily unavailable
can't get debug descriptor: Resource temporarily unavailable
Device Status:     0x0000
  (Bus Powered)
```