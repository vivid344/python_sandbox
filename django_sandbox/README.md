# Django Sandbox
## 概要
これはpipenvを用いたDjangoプロジェクトをHerokuにデプロイするときに使うSandboxになります．
pipenvはpipでインストールできます．
## 開発環境
* Mac OS 10.13.6
* python 3.7
* Herokuの環境構築済み
## 1.ローカル環境での動作確認
リポジトリをクローンしてきた後に，django_sandboxに移動し，以下のコマンドを実行します．
```
$ pipenv install
```
必要なパッケージのダウンロードを行います．

```
$ pipenv run start
```
Pipfileに書かれたscriptsのstartのコマンドを実行します．

今回の場合はDjangoプロジェクトをスタートします．
以下のURLにアクセスし，正常に動いてるかどうかを確認して下さい．

[http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## 2.Herokuにデプロイ

```
$ heroku create
$ heroku git:remote -a [上記実行時に出たアプリケーション名] 
$ heroku config:set DISABLE_COLLECTSTATIC=1
$ git init
$ git add .
$ git commit -m “first commit”
$ git push heroku master
$ heroku run python manage.py migrate
```


## 付録1：コマンドについて
pipenvを用いているのでコマンドを使う際は以下のようにする必要があります．
```
$ pipenv run [コマンド]
```

以下，よく使うコマンドを使いやすいようにしました．

### アプリの作成
```
$ pipenv run app hoge
```
`hoge`というアプリの作成する．（名前は任意に置き換えて下さい）

### マイグレーションの作成
```
$ pipenv run make
```
差分を監視し，マイグレーションの作成をします．

### マイグレーションを行う
```
$ pipenv run migrate
```
作成したマイグレーションを行います．

なにか必要なコマンドがあれば適時Pipfileに追記することで簡単に使えるようになります．．


## 2.ローカル環境での動作確認

## 付録2：APIの作成
### Modelの作成
まず，アプリの作成を行います．
```
$ pipenv run app hoge
```
`hoge`というアプリの作成後，新しくアプリができたことを追記するために django_sandbox/settings.py の INSTALLED_APPS に hogeを追記します．


```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'hoge',
]
```

モデルの作成を行います．hoge というアプリを作ったので，hoge/models.py にモデルを書きます．今回は以下のようなモデルにします．

```python
from django.db import models


class User(models.Model):
    user = models.CharField(max_length=255)
    message = models.CharField(max_length=255)
    date = models.DateTimeField()
```

モデルの詳細については
[こちら](https://docs.djangoproject.com/en/1.11/ref/models/fields/)
を御覧ください．

続いて，マイグレーションを行います．

```
$ pipenv run make
$ pipenv run migrate
```
以上で変更がデータベースに反映されます．

### Viewの作成
続いて，ビューを作成しJSONでデータベース内を表示できるようにします．



