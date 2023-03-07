# Trouble shooting
- GPUマシンにおけるセットアップでの`apt update`実行時に次のエラーが起こる可能性がある。    [その対処法](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/troubleshooting.html#conflicting-values-set-for-option-signed-by-error-when-running-apt-update)
    ```
    sudo apt-get update
    E: Conflicting values set for option Signed-By regarding source https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/amd64/ /: /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg !=
    E: The list of sources could not be read.
    ```
    2023-03-06あたりのアップデートでは、インストール手順に`etc/apt/sources.list.d/nvidia-container-toolkit.list`を作成するようになりました。このエラーが発生した場合、`signed-by`ディレクティブを指定しない同じリポジトリへの別の参照が存在することを意味します。最も可能性が高いのは、`/etc/apt/sources.list.d/` フォルダ内の `libnvidia-container.list`, `nvidia-docker.list`, `nvidia-container-runtime.list` のいずれか、または複数のファイルでしょう。

    さて、対処していきます。まず競合するリポジトリ参照を観察します。
    ```
    $ grep "nvidia.github.io" /etc/apt/sources.list.d/*
    ```
    リストアップされた競合する可能性のある参照のあるファイルを削除します。
    ```
    $ grep -l "nvidia.github.io" /etc/apt/sources.list.d/* | grep -vE "/nvidia-container-toolkit.list\$"
    ```

- `docker-compose up`等をしたときに次のエラーが起こる可能性がある。
    ```
    docker.errors.DockerException: Error while fetching server API version
    ```
    これは権限の問題である。`docker-compose up`を実行するユーザーを`docker`グループに追加する必要がある。  
    したがって、次のコマンドを実行し、ユーザーをグループに追加し、dockerを再起動する。
    ```
    $ sudo usermod -aG docker [username]
    $ su - $USER
    $ sudo systemctl restart docker
    ```
    **※今後でもPermissionエラーが起こったら次のコマンドでdockerのグループを起動する**
            ```
            $ newgrp docker
            ```
- ポートが既に使用されている状態の場合
    ```
    $ jupyter notebook list
    で一覧を表示し
    $ jupyter notebook stop [Port]
    でポート番号を指定してポートを解法する
    ```