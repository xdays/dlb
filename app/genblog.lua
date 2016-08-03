os.execute('export LANG=zh_CN.UTF-8 && cd /web/blog && pelican -s pelicanconf.py content/ -t theme/')
ngx.header.content_type = "text/html"
ngx.print('success\n')

return ngx.exit(ngx.HTTP_OK)
