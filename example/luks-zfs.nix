{
  disko.devices = {
    # 1. Define the physical disks
    disk = {
      # Disk 1
      x = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot"; # Systemd-boot looks here
                mountOptions = [ "umask=0077" ];
                # mountOptions = [ "nofail" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted_disk_1";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  keyFile = "/tmp/secret.key";
                };
                content = {
                  type = "zfs";
                  pool = "zroot"; # Assigns this decrypted dev to the pool below
                };
              };
            };
          };
        };
      };

      # Disk 2
      y = {
        type = "disk";
        device = "/dev/vdb";
        content = {
          type = "gpt";
          partitions = {
            # We don't strictly need another /boot, but empty space or a backup ESP is good
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted_disk_2";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  keyFile = "/tmp/secret.key";
                };
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };

      # Disk 3
      z = {
        type = "disk";
        device = "/dev/vdc";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted_disk_3";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  keyFile = "/tmp/secret.key";
                };
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
    };

    # 2. Define the ZFS Pool that aggregates the encrypted devices
    zpool = {
      zroot = {
        type = "zpool";
        mode = "raidz1";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
        };
        options.ashift = "12";
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
        };
      };
    };
  };
}
