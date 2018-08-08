# Django Sandbox
## 概要
これはpipenvを用いたDjangoプロジェクトをHerokuにデプロイするときに使うSandboxになります．
pipenvはpipでインストールできます．
## 開発環境
* Mac OS 10.13.6
* python 3.7.0（追記：Herokuは3.6.6までしか対応してない）
* Herokuの環境構築済み

## 1.ローカル環境での動作確認
リポジトリをクローンしてきた後に，django_sandboxに移動し，以下のコマンドを実行します．
```
$ pipenv install
```
以上のコマンドで必要なパッケージのダウンロードを行います．

```
$ pipenv run start
```
以上のコマンドでPipfileに書かれたscriptsのstartのコマンドを実行します．

今回の場合はDjangoプロジェクトをスタートします．
以下のURLにアクセスし，正常に動いてるかどうかを確認して下さい．

[http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## 2.Herokuにデプロイ
以下のコマンドを実行しHerokuの初期設定を行います．
```
$ heroku create
$ git remote add heroku [上記で出たgitのURL]
$ heroku config:set DISABLE_COLLECTSTATIC=1
```


続いてHerokuにデプロイするために以下のコマンドを実行します．
```
$ git init
$ git add .
$ git commit -m "first commit"
$ git push heroku master
$ heroku run python manage.py migrate
```
以上でHerokuへのデプロイが完了しました．


## 付録1：コマンドについて
pipenvを用いているのでコマンドを使う際は以下のようにする必要があります．
```
$ pipenv run [コマンド]
```

以下，よく使うコマンドを使いやすいように設定してあります．

### プロジェクトのスタート
```
$ pipenv run start
```
プロジェクトを開始します．

### アプリの作成
```
$ pipenv run app hoge
```
`hoge`というアプリの作成します．（名前は任意に置き換えて下さい）

### 管理者の作成
```
$ pipenv run user
```
管理サイトにアクセスすることのできるユーザを作成します．

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

なにか必要なコマンドがあれば適時Pipfileに追記することで簡単に使えるようになります．

## 付録2：APIの作成
### 1.Modelの作成
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

続いてモデルの作成を行います．hoge というアプリを作ったので，hoge/models.py にモデルを書きます．今回は以下のようなモデルにします．

```python
from django.db import models


class User(models.Model):
    user = models.CharField(max_length=255)
    message = models.CharField(max_length=255)
    date = models.DateTimeField()
    
    def __str__(self): #後述の管理サイトにデフォルトで表示される内容
        return self.message
```

モデルの詳細については
[こちら](https://docs.djangoproject.com/en/1.11/ref/models/fields/)
を御覧ください．

続いて，モデルの変更を反映させるためにマイグレーションを行います．

```
$ pipenv run make
$ pipenv run migrate
```
以上で変更がデータベースに反映されます．

### 2.管理者の作成
続いて管理者を作成し，管理サイトを見れるようにします．
```
$ pipenv run user
```
聞かれる質問に答え，ユーザの作成を行います．

その後，以下のURLにアクセスし，ログインを行います．

[http://127.0.0.1:8000/admin](http://127.0.0.1:8000/admin)


現在ではグループとユーザしか見えないので，先ほど作成したモデルが見えるようにします．

hoge/admin.pyを以下のように変更します．

```python
from django.contrib import admin
from hoge.models import User


class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'username', 'message', 'date',) # ここで指定したカラムが表示される
    

admin.site.register(User, UserAdmin)
```

再度，以下のURLにアクセスし，表示項目が増えていることを確認します．

[http://127.0.0.1:8000/admin](http://127.0.0.1:8000/admin)

ここでデータの追加や削除なども行えます．



### 3.Viewの作成
最後にJSONでデータベース内を表示できるようにします．

hoge/view.pyを以下のようにします．

```python
import json
from hoge.models import User
from django.http import HttpResponse


def Data(request):
    if request.method == 'GET':
        users = []
        for user in User.objects.all().order_by('id'):
            res = {
                'id': user.id,
                'name': user.username,
                'message': user.message,
                'date': str(user.date)
            }

            users.append(res)

        response = json.dumps(users, ensure_ascii=False)
        return HttpResponse(response, content_type='text/javascript')
```
上記のコードはリクエストのメソッドがGETの際にオブジェクトをidでソートし，全件表示させるものです．

取得する際に使用できるquerysetについては[こちら](https://docs.djangoproject.com/en/2.1/ref/models/querysets/#django.db.models.query.QuerySet)を御覧ください．


最後にルーティングの設定を行います．

django_sandbox/urls.pyを以下のようにします．
```python
from django.contrib import admin
from django.urls import path
from hoge import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('users/', views.Data)
]
```
これで先程記述したviews.pyのData関数が呼び出される仕組みになっています．

以下のURLにアクセスし，JSONが表示されるか試してみて下さい．

[http://127.0.0.1:8000/users/](http://127.0.0.1:8000/users/)

以上でAPIの作成は終わりです．お疲れ様でした．