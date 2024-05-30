# Setting up Kyte
Run the following as part of the start up script or in your EC2 Amazon Linxu 2023 instance.

`curl -sSL https://raw.githubusercontent.com/keyqcloud/kyte-ec2-init/main/ec2init.sh | bash`

# OPcache

Recommended settings to change or enable

```
zend_extension=opcache
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.huge_code_pages=1
```

See details:
https://www.php.net/manual/en/opcache.installation.php#opcache.installation.recommended

# APM

Move the `kyte_apm.service` file to `/etc/systemd/system/kyte_apm.service`

Move the `kyte_apm.timer` file to `/etc/systemd/system/kyte_apm.timer`

Reload deamons
```bash
sudo systemctl daemon-reload
```

Enable and start timer for apm
```bash
sudo systemctl enable memory_cpu_monitor.timer
sudo systemctl start memory_cpu_monitor.timer
```

To check the status
```bash
sudo systemctl status memory_cpu_monitor.timer
```

To test that the apm is working, install `stress`
```bash
sudo dnf install stress -y
```

To test CPU load
```
stress --cpu 8 --timeout 120
```

To test memory load (set the size to more than 65% of the provisioned RAM)
```
stress --vm 1 --vm-bytes 1G --timeout 120
```
