# Trouble shooting

## Docker、docker-compose
### `docker-compose up`等をしたときに次のエラーが起こる可能性がある。
```
docker.errors.DockerException: Error while fetching server API version
```
これは権限の問題である。`docker-compose up`を実行するユーザーを`docker`グループに追加する必要がある。  
したがって、次のコマンドを実行し、ユーザーをグループに追加し、dockerを再起動する。
```sh
$ sudo usermod -aG docker $USER
$ su - $USER
$ sudo systemctl restart docker
```
**※今後もPermissionエラーが起こったら次のコマンドでdockerのグループを起動する**
```sh
$ newgrp docker
```

## nvidia-docker
### GPUマシンにおけるセットアップでの`apt update`実行時に次のエラーが起こる可能性がある。
```sh
sudo apt-get update
```
```
E: Conflicting values set for option Signed-By regarding source https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/amd64/ /: /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg !=
E: The list of sources could not be read.
```
2023-03-06あたりのアップデートでは、インストール手順に`etc/apt/sources.list.d/nvidia-container-toolkit.list`を作成するようになりました。このエラーが発生した場合、`signed-by`ディレクティブを指定しない同じリポジトリへの別の参照が存在することを意味します。最も可能性が高いのは、`/etc/apt/sources.list.d/` フォルダ内の `libnvidia-container.list`, `nvidia-docker.list`, `nvidia-container-runtime.list` のいずれか、または複数のファイルでしょう。

さて、対処していきます。まず競合するリポジトリ参照を観察します。
```sh
$ grep "nvidia.github.io" /etc/apt/sources.list.d/*
```
リストアップされた競合する可能性のある参照のあるファイルを削除します。
```sh
$ grep -l "nvidia.github.io" /etc/apt/sources.list.d/* | grep -vE "/nvidia-container-toolkit.list\$"
```

## Ubuntu GPU
### ubuntu-drivers installで`UnboudLocalError`が起こったら
```sh
$ sudo ubuntu-drivers install
```
を実行した際に，
```
UnboundLocalError: local variable 'version' referenced before assignment
```
が発生した場合，"usr/lib/python3/dist-package/UbuntuDrivers/detect.py"の約835行目を次のように書き直すと問題が解消しました．
```python
version = int(package_name.split('-')[-1])
↓
version = int(package_name.split('-')[-2)
```

### `nvidia-smi`を実行したときに，`Unable to determine the device handle for GPU 0000:0?:00.0: Not Found`というエラーが起こったら[Link](https://forums.developer.nvidia.com/t/unable-to-determine-the-device-handle-for-gpu-000000-0-not-found/231710)
※?の箇所は1だったり7だったりする

- recommendedなnvidia-driverの番号を覚える
    ```sh
    $ ubuntu-drivers devices
    ```
- UbuntuのApplicationsからAdditional driversを探し，上記で見つけた番号の **non** `open-kernel`のものに切り替える
- `Apply Changes`を押下し，`Restart`を押下し再起動
- `nvidia-smi`コマンドで確認

### `nvidia-smi`を実行した時に`Failed to initialize NVML: Driver/library version mismatch`というエラーが発生した時[Link](https://qiita.com/ell/items/be3d3527b723f70f888d)
- 再起動する
    ```sh
    $ sudo reboot
    ```

### Docker内でGPUが使えない（`nvidia-smi`を実行したときに`Failed to initialize NVML: Unknown Error)の場合の対応[Link](https://qiita.com/k_ikasumipowder/items/5e71208b7c7ae3e4fe7c)
- ホストマシンでは`nvidia-smi`が実行できるのに、コンテナ内では実行できないとき
- `/etc/nvidia-container-runtime/config.toml`を次の様に書き換える
    ```toml
    no-cgroups = false
    ```
- dockerを再起動する
    ```sh
    sudo systemctl restart docker
    ```

### `ubuntu-drivers`で`autoinstall`し、Ethernetドライバが消えた場合 [Link](https://www.shangtian.tokyo/entry/2022/10/07/203104)
- 概要
    1. 目標はUbuntuマシンに`.deb`パッケージを用いてドライバをインストールする
    2. まず、別マシンでドライバのインストーラをダウンロードする
    3. ファイルを展開し、USBdiskに展開する
    4. USBdiskからUbuntuマシンにインストーラをコピーし`.deb`パッケージをインストールする
- 詳細
    1. 現在のカーネルと今あるEthernetドライバを確認する
        ```sh
        $ uname -r
        $ ls /lib/modules/[上記の出力]/kernel/drivers/net/ethernet/realtek/
        ```
    2. Ethernetドライバのインストール
        1. 別のpcにて、Ethernetドライバのインストーラ(例えば[realtek RTL8168B](https://www.realtek.com/ja/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software))をダウンロードし、解凍する
        2. USB等を用いて、Ubuntuマシンにドライバのインストーラのフォルダをコピーする
        3. インストーラを実行する
            - realtek RTL8168BBの場合`autorun.sh`を実行する
    3. 上記`autorun.sh`の実行にて次のエラーが発生した場合
        ```sh
        Check old driver and unload it.
        Build the module and install
        autorun.sh: 31: make: not found
        ```
        1. `build-essential`をインストールする
            1. Ubuntuマシンで`build-essential`に必要なものの`deb`ファイルのurlを保存する
                ```sh
                $ sudo apt-get --print-uris install build-essential* | cut -d\' -f2 | grep http:// > [対象のフォルダ]/urls.txt
                ```
            2. linuxもしくはmacの別pcにurlを記述したファイル(`url.txt`)をUSBを用いてコピーする
            3. `wget`コマンドを用いてそれらの`deb`ファイルをダウンロードし、フォルダにまとめておく
                ```sh
                $ wget -P [対象のフォルダのパス] -i urls.txt
                ```
            4. USBを用いてUbuntuマシンに上記フォルダをコピーし、`dpkg`コマンドを用いて`deb`パッケージをインストールする
                ```sh
                $ sudo dpkg -i --force-all [フォルダのパス]/*.deb
                ```
        2. また`autorun.sh`を実行し、次のエラーが発生した場合
            ```sh
            Check old driver and unload it.
            Build the module and install
            make[2]: *** /lib/modules/5.15.0-67-generic/build: No such file or directory. Stop.
            make[1]: *** [Makefile:162: clean] Error 2
            make: *** [Makefile:48: clean] Error 2
            ```
            - `linux-generic`をインストールする [Link](https://askubuntu.com/questions/554624/how-to-resolve-the-lib-modules-3-13-0-27-generic-build-no-such-file-or-direct)
                1. 必要なものの`deb`ファイルのurlを保存する
                    ```sh
                    $ sudo apt-get --print-uris install linux-generic | cut -d\' -f2 | grep http:// > [対象のフォルダ]/urls.txt
                    ```
                2. 上記`build-essential`の2~4と同じことをする
        3. `autorun.sh`を実行する
            - カーネルのバージョンが上がりそちらで動作するようになる

#### 付録
- USBをマウント、アンマウントする方法
    1. 認識場所の確認
        ```sh
        # 1. USBデバイス未接続の状態で、現在の認識状態を確認
        $ ls /dev/sd*
        # 2. USBデバイスを接続し、同様に確認して、未接続状態の時との違いを検索
        # （この時、末尾に数字のついているものを優先）
        $ ls /dev/sd*
        ```
    2. USBメモリのマウント
        ```sh
        $ sudo mount -t vfat /dev/[見当をつけた場所] /media
        ```
    3. ファイルのコピー
        ```sh
        $ cp /media/[ファイル名] [コピー先のパス]
        ```
    4. USBメモリのアンマウント
        ```sh
        $ sudo umount /dev/[マウントしたもの]
        ```
        



## jupyter
### ポートが既に使用されている状態の場合
```sh
$ jupyter notebook list
で一覧を表示し
$ jupyter notebook stop [Port]
でポート番号を指定してポートを解法する
```