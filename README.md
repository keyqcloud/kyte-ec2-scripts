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