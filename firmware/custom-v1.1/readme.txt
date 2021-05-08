注意 刷完此固件 无法模拟键盘按键输入 但是可以刷回群里的官方固件
Update to the custom firmware:
1. Unplug both cable on your TASOLLER. During the whole process, LED power cable shouldn't be connected,
2. Open "Update V1.1.exe" in the `Firmware` folder.
3. Keep Fn2 ( left button ) pressed and plug in "PC" cable.
4. Click `Connect` in the updater, browse to `Host.bin`, and start the update.
5. Once finished, click `Disconnect` and unplug "PC" cable.
6. Keep Fn1 ( right button ) pressed and plug in "PC" cable.
7. Click `Connect` in the updater, browse to `LED.bin`, and start the update.
8. Once finished, click `Disconnect` and unplug "PC" cable.
9. Reconnect both cable.
 
> If your firmware updated successfully, the default lighting will turn into rainbow on idle and stops working as a keyboard. The USB vendor ID will become `0x1CCF` and device ID will be `0x2333` as some of yours bad interest.
 
Drivers:
 
Open `Zadig`, choose `I SAY NYA-O` in the device list, then scroll the driver selector to `WinUSB`, and click `INSTALL DRIVER`.
 
If you can't find it in the device list, try connecting to another USB port on your PC.
 
Hooks:
 
From `chuniio` folder, copy `chuniio.dll` and `libusb-1.0.dll` to `bin` of the game. `chuniio.dll` will be replaced, remember to backup your original one.
 
Start your CHUNI*** and it should be working.

机翻
更新到自定义固件：
1.拔下TASOLLER上的两根电缆。
在整个过程中，LED电源线不能连接，
2.打开`Firmware`文件夹中的[更新V1.1.exe]。
3.保持按住Fn2(左键)并插入“PC”线缆。
4.点击更新器中的`Connect`，浏览至`Host.bin`，开始更新。
5.完成后，点击`断开连接`，拔掉PC线缆。
6.按住Fn1(右按钮)并插入“PC”电缆。
7.点击更新器中的`Connect`，浏览至`LED.bin`，开始更新。
8.完成后，点击`断开连接`，拔掉PC线缆。
9.重新连接两根电缆。
>如果您的固件更新成功，默认照明将变为空闲时的彩虹，不再作为键盘使用。
USB厂商ID将变为`0x1CCF`，设备ID将变为`0x2333`，这与您的一些不良兴趣有关。
驱动因素：
打开`Zadig`，在设备列表中选择`I Say NYA-o`，然后将驱动选择器滚动到`WinUSB`，点击`INSTALL DRIVER`。
如果在设备列表中找不到，请尝试连接到电脑上的另一个USB端口。
挂钩：
从`chuniio`文件夹复制游戏的`chuniio.dll`和`libusb-1.0.dll`到`bin`。
`chuniio.dll`将被替换，请记住备份您原来的。
启动你的Chuni*，它应该会起作用。