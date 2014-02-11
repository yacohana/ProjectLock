# Project Lock

Easily check/make/delete lockfile status to avoid confliction, for example, some people use the same server.  
This is just an advisory lock, so you should use this with all agreement.

## Usage

* check status -> `./plock.sh`
* toggle lock status -> `./plock.sh yourname`
* lock -> `./plock.sh -l yourname`
* lock with message(optional) -> `./plock.sh -l yourname message`
* unlock -> `./plock.sh -u`

## 説明

よくある排他的ファイル操作を、シェルから簡単に出来るようにしたスクリプト。
バイトのついでに作成したものを公開。プロジェクトで共用サーバー使うときなど。  
詳細はUsage参照。ファイル呼ぶの面倒なのでaliasしよう。  
始めてシェルスクリプト始めてだったので、色々ご勘弁。

## License

MIT: http://rem.mit-license.org