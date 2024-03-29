# Ubuntu22.04 GPUマシンのセットアップ

## Ubuntuセットアップ
1. USBインストーラーを用意し，インストールする
    - USBインストーラーを用意する
        - [Download Ubuntu Desktop](https://ubuntu.com/download/desktop)にアクセスする
        - Ubuntu 22.04 LTSの右にある`Download`ボタンを押すとダウンロードが始まる
        - 入手したISOファイルを書き込みソフトを使用してUSBメモリーに書き込む
    - GPUマシンにUbuntuをインストールする
        - GPUマシンにUSBインストーラーを差し込み，電源をONにし，[F2]を押す
        - BIOSが起動したら，`起動`のメニューを選択し，差し込んだUSBの優先順位を1番にし，USBを選択して起動する．
        - `Install Ubuntu`を選択する．


2. 日本語を入力したい場合は，日本語入力に対応させる [Link](https://hirooka.pro/ubuntu-22-04-lts-japanese-input-ibus-fcitx-mozc/)
    - 画面右上をクリックすると出てくるポップアップに`Settings`がある．それをクリックして`Settings`を起動する．
    - `Settings`のサイドバーから`Region & Language`を選択し，`Manage Installed Languages`ボタンをクリックる．
        - 初回起動時は`The language support is not installed completely`と表示される．
        - `Install`ボタンをクリックする
    - インストール完了後，`Language Support`ウィンドウの`Keyboard input method system`で`IBus`を選択し，"Close"ボタンをクリックする（デフォルトで"IBus"に設定されているらしい）．
    - 一度ログアウトし，再度ログインする．
    - 画面右上に「A」というアイコンが表示されるようになっていると思う．
    - `Settings`を開き，`Settings`のサイドバーから`Keyboard`を開く．
        - `Input Sources`に`Japanese(Mozc)`が追加されていることを確認する．
    - 画面右上の「A」アイコンをクリックし，`Japanese(Mozc)`を選択する．

## NVIDIA Driverセットアップ [Link](https://hirooka.pro/nvidia-driver-ubuntu-22-04/)
※BIOSのセキュアブートを無効化しないと、ドライバのインストール終盤に`Configuring Secure Boot`が発生し、ドライバのインストールをやり直すことになります。一応、そうなった場合でも対処はできますが、出来ているのかイマイチわかりずらいためおすすめしません。
1. まず，コマンドラインを開く
    `Ctrl+Alt+t`もしくは，左上の`Activities`から探す．
2. 現状入っているCUDA、nvidia-driverの確認
    ```sh
    $ dpkg -l | grep nvidia
    $ dpkg -l | grep cuda
    ```
3. 現状入っているCUDA、nvidia-driverの削除
    ```sh
    $ sudo apt-get --purge remove nvidia-*
    $ sudo apt-get --purge remove cuda-*
    ```
4. インストールできそうなドライバー一覧を確認してみる．
    ```sh
    $ sudo apt update
    $ ubuntu-drivers devices
    ```
    - `ubuntu-drivers`が使えない場合
        ```sh
        $ sudo apt install -y ubuntu-drivers-common
        ```
5. recommended(推奨)されているドライバをインストールし、OSを再起動する [Link](https://qiita.com/karaage0703/items/e79a8ad2f57abc6872aa)
    - **autoinstall**する方法もあるが、次のようなトラブルが散見されるため**非推奨**である
        - 黒画面になる
        - ネットワークが突然死ぬ（Ethernetドライバが消える）
    - **手動(apt)でインストールする**
        1. インストールするべきドライバを確認する（上記）
            ※`-open`とされているドライバーをインストールするとトラブルが発生することが多い。`recommended`が付いているバージョンの`**non** -open`をインストールするべし[Link](https://qiita.com/y-vectorfield/items/72bfb66d8ec85847fe2f)。
        2. aptでお目当てのドライバをインストールする
            ```sh
            $ sudo apt install nvidia-driver-xxx
            ```
        3. 再起動する
            ```sh
            $ sudo reboot
            ```
6. `nvidia-smi`コマンドを実行し、ドライバのバージョンとCUDAのバージョンを確認する
    ```sh
    $ nvidia-smi
    ```

## Windowsリモートデスクトップでアクセスできるようにする
1. コマンドラインからリモートデスクトップをインストールします
    ```sh
    $ sudo apt install xrdp
    ```
2. MATEデスクトップを導入するために次のコマンドを実行してください．
    ```sh
    $ sudo apt install mate-desktop-environment
    $ sudo apt install mate-desktop-environment-extras
    ```
3. `/etc/xrdp/startwm.sh`を編集し，最終行の`./etc/X11/Xsession`を消して`mate-session`に変更してください

4. リモートデスクトップを起動してください
    ```sh
    $ sudo service xrdp restart
    ```
5. ログアウトし，windowsリモートデスクトップでアクセスしてください．
    - ログアウトをしていないと，アクセスした時に画面が表示されなくなるため，必ずログアウトしてください．
    - もし，画面が真っ黒な場合はGPUマシンのOSを再起動してください


## gitをインストールする
    - aptを最新版にアップデートしてください
    ```sh
    $ sudo apt update
    ```
    - gitをインストールし，インストールを確認してください
    ```sh
    $ sudo apt install git
    $ git --version
    ```


# Appendix
- if (condaのPATHを初期設定し忘れた)
    ```sh
    $ export PATH=$PATH:/home/ubuntu/anaconda3/bin/
    ```

- emacsのインストール
    ```sh
    $ sudo apt install emacs
    ```

- ubuntu20.04~22.04でxrdpで接続したときにDockが表示されないときの対処法[Link](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0621)
    - 次のスクリプトを`enhanced-session-mode.sh`とし，実行する
        ```sh
        #!/bin/sh

        # Add script to setup the ubuntu session properly
        if [ ! -e /etc/xrdp/startubuntu.sh ]; then
        cat >> /etc/xrdp/startubuntu.sh << EOF
        #!/bin/sh
        export GNOME_SHELL_SESSION_MODE=ubuntu
        export XDG_CURRENT_DESKTOP=ubuntu:GNOME
        exec /etc/xrdp/startwm.sh
        EOF
        chmod a+x /etc/xrdp/startubuntu.sh
        fi

        sed -i_orig -e 's/startwm/startubuntu/g' /etc/xrdp/sesman.ini

        # rename the redirected drives to 'shared-drives'
        sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

        # Changed the allowed_users
        sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

        # Configure the policy xrdp session
        cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla <<EOF
        [Allow Colord all Users]
        Identity=unix-user:*
        Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
        ResultAny=no
        ResultInactive=no
        ResultActive=yes
        EOF

        # https://askubuntu.com/questions/1193810/authentication-required-to-refresh-system-repositories-in-ubuntu-19-10
        cat > /etc/polkit-1/localauthority/50-local.d/46-allow-update-repo.pkla<<EOF
        [Allow Package Management all Users]
        Identity=unix-user:*
        Action=org.freedesktop.packagekit.system-sources-refresh
        ResultAny=yes
        ResultInactive=yes
        ResultActive=yes
        EOF
        ```
    - このコードは3～20行目がxrdp自体の設定であり，22～40行目がxrdp使用中にしょっちゅうパスワードが聞かれることを防ぐ設定．
    - これを実行する
        ```sh
        $ sudo bash ./enhanced-session-mode.sh
        ```
    - 実行後は再起動する．

