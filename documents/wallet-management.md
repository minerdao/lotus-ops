# Lotus钱包常用操作

列出钱包地址:
```sh
$ lotus wallet list
```

查看余额:
```sh
$ lotus wallet balance <WALLET_ADDRESS>
```

默认钱包地址:
```sh
$ lotus wallet default
```

设置默认钱包地址:
```sh
$ lotus wallet set-default <WALLET_ADDRESS>
# 例如: lotus wallet set-default fxxxx001
```

从默认钱包地址发送代币:
```sh
$ lotus send <TARGET_ADDRESS> <AMOUNT>
# 例如: lotus send fxxxxx001 10
```

从指定钱包地址发送代币:
```sh
$ lotus send --from=<SENDER_ADDRESS> <TARGET_ADDRESS> <AMOUNT>
# 例如: lotus send --from=fxxxxxx002 fxxxxxx001 3
```

导出钱包地址:
```sh
$ lotus wallet export <WALLET_ADDRESS>
# 例如: lotus wallet export fxxxxx001 > fxxxxx001.key
```

导入钱包地址:
```sh
$ lotus wallet import <WALLET_ADDRESS>.key
# 例如: lotus wallet import fxxxxx001.key
```