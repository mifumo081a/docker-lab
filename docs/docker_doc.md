# Docker document
## Dockerとは
ImageとContainerというコンポーネントを基にLinuxカーネルの機能を用いて１つのプロセスとして隔離された仮想環境を実現するもの。

# Quick start
## インストール
- For Windows
    1. WSL2のインストール
        管理者権限でコマンドプロンプトを起動し、以下のコマンドを実行する
        ```sh
        wsl --install
        ```
    1. `Docker Desktop Installer.exe`を起動する
        `Docker Desktop Installer.exe`は[Docker Hub](https://hub.docker.com/editions/community/docker-ce-desktop-windows/)からダウンロードできる
    2. 確認画面が出たら、`Use WSL 2 instead of Hyper-V`をチェックして進める。
    2. 管理者(admin)アカウントと使用中のアカウントが異なる場合、`docker-users`グループにユーザを追加する必要がある。Windowsの`コンピュータを管理`を管理者として起動し、`ローカルグループ ユーザーとグループ > グループ > docker-users`を右クリックし、対象ユーザをグループに追加する。ログアウトすると設定が有効になっている。
    3. Windowsの場合は、docker-composeもインストールされている。

- For Linux(Ubuntu LTS 18.04, 20.04, and 22.04)
    - Docker
        1. 次のコマンドを実行する[Link](https://docs.docker.com/engine/install/ubuntu/)
            ```sh
            $ sudo apt-get update
            $ sudo apt-get install ca-certificates curl gnupg lsb-release
            $ sudo mkdir -m 0755 -p /etc/apt/keyrings
            $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            $ echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            $ sudo apt-get update
            $ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ```
        2. 動作確認
            - バージョン確認
                ```sh
                $ docker --version
                ```
            - Hello world
                ```sh
                $ sudo docker run hello-world
                ```
    - docker-compose[Link](https://www.server-world.info/query?os=Ubuntu_22.04&p=docker&f=7)
        1. 次のコマンドを実行する
            ```sh
            $ sudo apt install docker-compose
            ```
        2. 動作確認
            - バージョン確認
                ```sh
                $ docker-compose version
                ```
    - ユーザーをdockerグループに入れる[Link](https://docs.docker.com/engine/install/linux-postinstall/)
        1. 現状のグループの設定の確認
            ```sh
            $ cat /etc/group | grep docker
            ```
            **グループがない場合は**自分で作成する
            ```sh
            $ sudo groupadd docker
            ```
        2. ユーザーを`docker`グループに追加する
            ```sh
            $ sudo usermod -aG docker $USER
            ```
        3. dockerを再起動する
            ```sh
            $ sudo systemctl restart docker
            ```
        4. `docker`グループを有効にする
            ```sh
            $ newgrp docker
            ```

# Appendix
## 節約術

- Windows[Link](https://zenn.dev/takajun/articles/4f15d115548899)
    タスクマネージャー等で`Vmmem`なるものがメモリ使用量を多く占有していることがある。これはWSL2が使用しているものであり、これを制限することができる。
    **仮想マシンのメモリ使用量を設定する**
    `C:\Users\[username]\.wslconfig`を書くことで、いろいろ設定できる。ここにメモリの使用量を設定する。
    **.wslconfig**
    ```
    [wsl2]
    memory=2GB
    ```
        
- Linux(Ubuntu)
    - 使用していないDockerオブジェクトの削除（prune）
        以下のコマンドを用いることで使っていないイメージを削除することができます。
        ```sh
        $ docker image prune
        ```
