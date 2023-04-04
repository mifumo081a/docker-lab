# Trouble shooting

## docker
- `docker-compose up`等をしたときに次のエラーが起こる可能性がある。
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
- GPUマシンにおけるセットアップでの`apt update`実行時に次のエラーが起こる可能性がある。
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

## GPU machine
- ubuntu-drivers installで`UnboudLocalError`が起こったら
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

- `nvidia-smi`を実行したときに，`Unable to determine the device handle for GPU 0000:0?:00.0: Not Found`というエラーが起こったら[Link](https://forums.developer.nvidia.com/t/unable-to-determine-the-device-handle-for-gpu-000000-0-not-found/231710)
    ※?の箇所は1だったり7だったりする

    - recommendedなnvidia-driverの番号を覚える
        ```sh
        $ ubuntu-drivers devices
        ```
    - UbuntuのApplicationsからAdditional driversを探し，上記で見つけた番号の **non** `open-kernel`のものに切り替える
    - `Apply Changes`を押下し，`Restart`を押下し再起動
    - `nvidia-smi`コマンドで確認

- `nvidia-smi`を実行した時に`Failed to initialize NVML: Driver/library version mismatch`というエラーが発生した時[Link](https://qiita.com/ell/items/be3d3527b723f70f888d)
    - 再起動する
        ```sh
        $ sudo reboot
        ```



## jupyter
- ポートが既に使用されている状態の場合
    ```sh
    $ jupyter notebook list
    で一覧を表示し
    $ jupyter notebook stop [Port]
    でポート番号を指定してポートを解法する
    ```