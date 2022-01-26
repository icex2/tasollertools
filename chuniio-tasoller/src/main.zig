const std = @import("std");
const win32 = @import("zigwin32/win32.zig");

const DWORD = std.os.windows.DWORD;
const HRESULT = std.os.windows.HRESULT;
const S_OK = std.os.windows.S_OK;
const E_FAIL = std.os.windows.E_FAIL;
const INVALID_HANDLE_VALUE = win32.foundation.INVALID_HANDLE_VALUE;
const GetLastError = win32.foundation.GetLastError;
const GetAsyncKeyState = win32.ui.input.keyboard_and_mouse.GetAsyncKeyState;
const GetPrivateProfileIntA = win32.system.windows_programming.GetPrivateProfileIntA;

const GENERIC_READ = win32.system.system_services.GENERIC_READ;
const GENERIC_WRITE = win32.system.system_services.GENERIC_WRITE;
const OPEN_EXISTING = win32.storage.file_system.OPEN_EXISTING;
const FILE_ACCESS_FLAGS = win32.storage.file_system.FILE_ACCESS_FLAGS;
const FILE_SHARE_MODE = win32.storage.file_system.FILE_SHARE_MODE;
const FILE_SHARE_READ = win32.storage.file_system.FILE_SHARE_READ;
const FILE_SHARE_WRITE = win32.storage.file_system.FILE_SHARE_WRITE;
const CreateFileA = win32.storage.file_system.CreateFileA;

const GUID_DEVINTERFACE_USB_DEVICE = win32.devices.usb.GUID_DEVINTERFACE_USB_DEVICE;
const DIGCF_PRESENT = win32.devices.device_and_driver_installation.DIGCF_PRESENT;
const DIGCF_DEVICEINTERFACE = win32.devices.device_and_driver_installation.DIGCF_DEVICEINTERFACE;
const SP_DEVICE_INTERFACE_DATA = win32.devices.device_and_driver_installation.SP_DEVICE_INTERFACE_DATA;
const SP_DEVICE_INTERFACE_DETAIL_DATA_A = win32.devices.device_and_driver_installation.SP_DEVICE_INTERFACE_DETAIL_DATA_A;
const SetupDiGetClassDevsW = win32.devices.device_and_driver_installation.SetupDiGetClassDevsW;
const SetupDiDestroyDeviceInfoList = win32.devices.device_and_driver_installation.SetupDiDestroyDeviceInfoList;
const SetupDiEnumDeviceInterfaces = win32.devices.device_and_driver_installation.SetupDiEnumDeviceInterfaces;
const SetupDiGetDeviceInterfaceDetailA = win32.devices.device_and_driver_installation.SetupDiGetDeviceInterfaceDetailA;
const WinUsb_Initialize = win32.devices.usb.WinUsb_Initialize;
const WinUsb_WritePipe = win32.devices.usb.WinUsb_WritePipe;
const WinUsb_ReadPipe = win32.devices.usb.WinUsb_ReadPipe;

const chuni_io_slider_callback_t = ?fn ([*c]const u8) callconv(.C) void;

const Config = struct {
    test_key: i32,
    serv_key: i32,
    coin_key: i32,
};

var cfg: ?Config = null;
var thread_op = std.Thread.Mutex{};
var slider_active = false;
var slider_thread: ?std.Thread = null;
var input_thread: ?std.Thread = null;

var usb_out_op = std.Thread.Mutex{};
var usb_out = std.mem.zeroes([80*3]u8);
var usb_in = std.mem.zeroes([0x24]u8);
var tasoller: ?*anyopaque = null;

fn tasoller_init() !void {

    const hDevInfo = SetupDiGetClassDevsW(&GUID_DEVINTERFACE_USB_DEVICE, null, null, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if(hDevInfo == INVALID_HANDLE_VALUE) {
        std.log.err("[chuniio] SetupDiGetClassDevs: {any}", .{GetLastError()});
        return error.AccessError;
    }
    defer _ = SetupDiDestroyDeviceInfoList(hDevInfo);
    
    var ifIdx: DWORD = 0;
    var devIf = std.mem.zeroes(SP_DEVICE_INTERFACE_DATA);
    devIf.cbSize = @sizeOf(SP_DEVICE_INTERFACE_DATA);
    var devicePath: ?[*:0]const u8 = null;
    while(SetupDiEnumDeviceInterfaces(hDevInfo, null, &GUID_DEVINTERFACE_USB_DEVICE, ifIdx, &devIf) != 0) : (ifIdx += 1) {
        var requiredSize: u32 = 0;
        var detailBuf = std.mem.zeroes([263]u8);
        var devIfDetail = @ptrCast(*SP_DEVICE_INTERFACE_DETAIL_DATA_A, &detailBuf);
        devIfDetail.cbSize = @sizeOf(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
        if(SetupDiGetDeviceInterfaceDetailA(hDevInfo, &devIf, devIfDetail, 263, &requiredSize, null) == 0) {
            std.log.err("[chuniio] SetupDiGetDeviceInterfaceDetailA: {any}", .{GetLastError()});
            continue;
        }
        if(requiredSize >= 263) {
            std.log.err("[chuniio] SetupDiGetDeviceInterfaceDetailA: Path too long", .{});
            continue;
        }
        const path = detailBuf[@offsetOf(SP_DEVICE_INTERFACE_DETAIL_DATA_A, "DevicePath") .. requiredSize :0];
        // std.log.info("[chuniio] devPath: {s}", .{path});
        if(std.mem.indexOf(u8, path, "vid_1ccf") == null) continue;
        if(std.mem.indexOf(u8, path, "pid_2333") == null) continue;
        devicePath = path;
        break;
    }
    if(devicePath == null) {
        std.log.err("[chuniio] Tasoller not found", .{});
        return error.AccessError;
    }

    const hDeviceHandle = CreateFileA(
        devicePath,
        @intToEnum(FILE_ACCESS_FLAGS, GENERIC_READ | GENERIC_WRITE),
        @intToEnum(FILE_SHARE_MODE, @enumToInt(FILE_SHARE_READ) | @enumToInt(FILE_SHARE_WRITE)),
        null, // Security Attributes
        OPEN_EXISTING,
        .FILE_FLAG_OVERLAPPED,
        null // Template File
    ) orelse {
        std.log.err("[chuniio] CreateFileA {s}: {any}", .{devicePath, GetLastError()});
        return error.AccessError;
    };
    if(hDeviceHandle == INVALID_HANDLE_VALUE) {
        std.log.err("[chuniio] CreateFileA {s}: {any}", .{devicePath, GetLastError()});
        return error.AccessError;
    }

    if(WinUsb_Initialize(hDeviceHandle, &tasoller) == 0) {
        std.log.err("[chuniio] WinUsb_Initialize: {any}", .{GetLastError()});
        return error.AccessError;
    }

    // Init magic bytes
    std.mem.copy(u8, usb_out[0..3], &[_]u8{0x42, 0x4C, 0x00});
}

// Poll input regardless of slider start/stop
fn input_thread_proc() void {
    while(true) {
        var len: u32 = 0;
        if(WinUsb_ReadPipe(tasoller, 0x84, @ptrCast(*u8, &usb_in), usb_in.len, &len, null) == 0) {
            std.log.warn("[chuniio] WinUsb_ReadPipe: {any}", .{GetLastError()});
        }
    }
}

fn slider_thread_proc(callback: chuni_io_slider_callback_t) void {
    var pressure = std.mem.zeroes([32]u8);
    while(slider_active) {
        // Tasoller order: top->bottom, left->right
        // Chunithm order: top->bottom, right->left
        for(usb_in[4..]) |val, i| pressure[if(i%2 == 0) 30-i else 32-i] = val;
        callback.?(&pressure);
        std.time.sleep(1_000_000); // 1ms
    }
}

export fn chuni_io_get_api_version() c_ushort {
    return 0x0101;
}

export fn chuni_io_jvs_init() HRESULT {
    const cfg_file = ".\\segatools.ini";
    cfg = .{
        .test_key = @intCast(i32, GetPrivateProfileIntA("io3", "test", 0x31, cfg_file)),
        .serv_key = @intCast(i32, GetPrivateProfileIntA("io3", "service", 0x32, cfg_file)),
        .coin_key = @intCast(i32, GetPrivateProfileIntA("io3", "coin", 0x33, cfg_file)),
    };
    tasoller_init() catch {
        return E_FAIL;
    };
    input_thread = std.Thread.spawn(.{}, input_thread_proc, .{}) catch |err| {
        std.log.err("[chuniio] Spawn input thread: {any}", .{err});
        return E_FAIL;
    };
    return S_OK;
}

export fn chuni_io_jvs_poll(opbtn: ?[*]u8, beams: ?[*]u8) void {
    if(opbtn == null or beams == null) return;
    if(GetAsyncKeyState(cfg.?.test_key) != 0 or (usb_in[3] & (1 << 7)) != 0) opbtn.?.* |= (1 << 0);
    if(GetAsyncKeyState(cfg.?.test_key) != 0 or (usb_in[3] & (1 << 6)) != 0) opbtn.?.* |= (1 << 1);
    beams.?.* |= usb_in[3] & 0b111111;
}

var coin_conter: c_ushort = 0;
var coin_prev_depressed = false;
export fn chuni_io_jvs_read_coin_counter(total: ?*c_ushort) void {
    if(total == null) return;
    const coin_depressed = GetAsyncKeyState(cfg.?.coin_key) != 0;
    if(coin_depressed and !coin_prev_depressed) coin_conter += 1;
    coin_prev_depressed = coin_depressed;
    total.?.* = coin_conter;
}

export fn chuni_io_slider_init() HRESULT {
    return S_OK;
}

export fn chuni_io_slider_start(callback: chuni_io_slider_callback_t) void {
    if(callback == null) return;
    thread_op.lock();
    defer thread_op.unlock();
    if(slider_thread == null) {
        slider_active = true;
        slider_thread = std.Thread.spawn(.{}, slider_thread_proc, .{callback}) catch |err| {
            std.log.err("[chuniio] Spawn slider thread: {any}", .{err});
            return {};
        };
    }
}

export fn chuni_io_slider_stop() void {
    thread_op.lock();
    defer thread_op.unlock();
    if(slider_thread != null) {
        slider_active = false;
        slider_thread.?.join();
        slider_thread = null;
    }
}

export fn chuni_io_slider_set_leds(rgb: ?[*]u8) void {
    if(rgb == null) return;
    
    var n: u32 = 0;
    const out = usb_out[3..96];
    while(n < 31) : (n += 1) {
        out[n*3+0] = rgb.?[n*3+2];
        out[n*3+1] = rgb.?[n*3+1];
        out[n*3+2] = rgb.?[n*3+0];
    }

    usb_out_op.lock();
    defer usb_out_op.unlock();
    if(WinUsb_WritePipe(tasoller, 0x03, @ptrCast(*u8, &usb_out), usb_out.len, &n, null) == 0) {
        std.log.warn("[chuniio] WinUsb_WritePipe: {any}", .{GetLastError()});
    }
}

pub fn main() !void {
    try tasoller_init();
}