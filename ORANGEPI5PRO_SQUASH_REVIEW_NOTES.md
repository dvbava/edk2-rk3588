# Orange Pi 5 Pro Squash Review Notes

These notes capture cleanup items found after squashing the Orange Pi 5 Pro work into one commit.

## Must Fix Before PR

### Remove generated image artifacts

The squashed commit includes:

```text
orangepi-5-pro_RAWEDK2.img
```

This is a generated firmware image and should not be committed. Remove it from the commit and add image outputs to `.gitignore`, for example:

```text
*_RAWEDK2.img
*_NOR_FLASH.img
```

### Split unrelated board changes

The commit is titled `Add support for Orange pi 5 Pro`, but it also modifies other boards and shared behavior. Keep the Orange Pi 5 Pro PR focused.

Move these to separate commits/branches or drop them from this PR:

```text
edk2-rockchip/Platform/Radxa/ROCK5A/ROCK5A.dsc
edk2-rockchip/Platform/Radxa/ROCK5BPlus/*
devicetree/mainline/rk3588-rock-5b-plus-fixup.dts
devicetree/mainline/rk3588s-rock-5a-fixup.dts
```

### Remove Secure Boot auto-enrollment changes

The squash includes broad Secure Boot changes in:

```text
build.sh
edk2-rockchip/Silicon/Rockchip/Library/PlatformBootManagerLib/PlatformBm.c
edk2-rockchip/Silicon/Rockchip/Library/PlatformBootManagerLib/PlatformBootManagerLib.inf
edk2-rockchip/Silicon/Rockchip/Rockchip.dsc.inc
```

This is risky and unrelated to Orange Pi 5 Pro board enablement.

Specific concern: `build.sh` generates a Platform Key certificate while discarding the private key. If firmware auto-enrolls that PK, the board can enter Secure Boot User Mode without a retained private key for future database changes.

### Drop local machine helper scripts from the PR

These are useful locally but should not be part of a general board support commit unless rewritten generically:

```text
docker-build.ps1
Dockerfile
Makefile
inject-wor-drivers.cmd
docker-build-command.ps1
docker-build-command.cmd
```

Current `docker-build.ps1` hardcodes:

```text
D:\codebase\edk2-rk3588
https://github.com/dvbava/edk2-rk3588.git
```

### Fix whitespace / line ending noise

`git diff --check origin/op5pro..HEAD` reports many whitespace issues. Some are CRLF-related, but the final PR should avoid churn where possible.

Run a cleanup pass after narrowing the commit scope.

## Keep In Orange Pi 5 Pro Support

These are expected to remain in the focused board-support commit:

```text
configs/orangepi-5-pro.conf
devicetree/mainline/rk3588s-orangepi-5-pro.dts
edk2-rockchip/Platform/OrangePi/OrangePi5Pro/*
README.md entries for Orange Pi 5 Pro
```

Also keep the proven USB3 hardening:

```text
edk2-rockchip/Silicon/Rockchip/RK3588/RK3588.dec
edk2-rockchip/Silicon/Rockchip/RK3588/Drivers/RK3588Dxe/RK3588Dxe.inf
edk2-rockchip/Silicon/Rockchip/RK3588/Drivers/RK3588Dxe/UsbDpPhy.c
edk2-rockchip/Platform/OrangePi/OrangePi5Pro/OrangePi5Pro.dsc
```

The key behavior to preserve:

```text
PcdUsbDpPhyForceUsb3Enabled
```

Orange Pi 5 Pro should force USB3 enabled at boot so stale UEFI variables cannot leave the USB3 boot path disabled.

## Current Stable Baseline

Known working baseline:

```text
Firmware: master with USB3 force-enabled hardening
Windows: clean image, no injected Rockchip driver pack
Boot path: USB3 port -> powered USB3 hub -> NVMe USB enclosure
```

Avoid preloading the full Rockchip Windows driver pack for now. It caused WHEA crashes. Test drivers individually after a clean Windows boot.

Suggested driver order:

1. Motorcomm YT6801 Ethernet only.
2. Reboot and verify stability.
3. Test Rockchip drivers one at a time.
4. Treat `usbehci` as risky; do not preload it into the Windows image.

## Suggested Final PR Shape

The clean PR should contain:

```text
Add Orange Pi 5 Pro platform files
Add Orange Pi 5 Pro DTS/config/README entries
Add minimal shared USB3 force-enable PCD support
```

Everything else should be separate:

```text
Secure Boot auto-enrollment
Radxa ROCK5A / ROCK5BPlus changes
Docker/local build helpers
RAWEDK2 image output changes, if still wanted
Shared OTP/FDT GMAC MAC-address changes
```
