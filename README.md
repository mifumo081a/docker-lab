# docker-lab
機械学習の実験・デモをするためのDocker環境です。

## Contents
- jupyter lab
- streamlit
- pytorch with GPU

# Preparations
1. Dockerをインストールする
2. docker compose(ver1.28.0>=)をインストールする
    - Mac, Windowsの場合はDockerインストール時に入ってる
3. 次のコマンドを実行して`.env`ファイルを作成する
    - For Windows
        ```
        $ bash set_DotEnv.sh
        ```
    - For Linux or Mac
        ```
        $ sh set_DotEnv.sh
        ```
4. GPUを使用するなら次を実行する
    - GPUドライバをインストールする
    - Nvidia Container Toolkitをセットアップする
        - For Windows
            WSLでgpuSetup.shを実行する
            ```
            $ bash gpuSetup.sh
            ```
        - For Linux or Mac
            gpu_setup.shを実行する
            ```
            $ sh gpuSetup.sh
            ```
    - 完了したらDocker Containerでnvidia-smiを実行して確認する
        ```
        $ sudo docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
        ```

# How to use

## build image
- With GPU
    ```
    $ docker-compose -f docker_gpu.yml build
    ```

- Without GPU
    ```
    $ docker-compose build
    ```

## up container
- With GPU
    ```
    $ docker-compose -f docker_gpu.yml up
    ```

- Without GPU
    ```
    $ docker-compose up
    ```

## サービス指定
- jupyter lab のみ
    上記のコマンドに次のように書き足し、ブラウザからlocalhost:8888にアクセス
    ```
    $ ~~up jupyterlab
    ```

- streamlit のみ
    上記のコマンドに次のように書き足し、ブラウザからlocalhost:8501にアクセス
    ```
    $ ~~up streamlit
    ```

# [TroubleShooting](trouble_shooting.md)
問題が発生した場合に読んでください。

# References
- https://zenn.dev/takeguchi/articles/361e12a5321095
- https://zenn.dev/akira_kashihara/articles/073b4b19a13840
- https://qiita.com/Sicut_study/items/32eb5dbaec514de4fc45
- https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker
- https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/troubleshooting.html
- https://mebee.info/2021/10/13/post-44471/
- https://life-is-miracle-wind.blog.jp/archives/30965602.html
- https://qiita.com/cheekykorkind/items/ba912b62d1f59ea1b41e
