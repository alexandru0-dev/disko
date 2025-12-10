{
  pkgs ? import <nixpkgs> { },
  diskoLib ? pkgs.callPackage ../lib { },
}:
diskoLib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "luks-zfs";
  extraInstallerConfig.networking.hostId = "8425e349";
  extraSystemConfig = {
    networking.hostId = "8425e349";
    boot.zfs.devNodes = pkgs.lib.mkForce "/dev/mapper";
  };
  disko-config = ../example/luks-zfs.nix;
  extraTestScript = ''
    machine.succeed("cryptsetup isLuks /dev/vda2")
    machine.succeed("cryptsetup isLuks /dev/vdb1")
    machine.succeed("cryptsetup isLuks /dev/vdc1")
    machine.succeed("zpool list -vP zroot | grep /dev/mapper/crypted_disk_1")
    machine.succeed("zpool list -vP zroot | grep /dev/mapper/crypted_disk_2")
    machine.succeed("zpool list -vP zroot | grep /dev/mapper/crypted_disk_3")
    machine.succeed("mountpoint /")
    machine.succeed("mountpoint /nix")
  '';
}
