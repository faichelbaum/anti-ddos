upstream VHOST.nginx_backend {
        server IP max_fails=1 fail_timeout=60;
}

server {
	server_name FQDN;
	listen cdn:80;

	location ~* (\.jpg|\.jpeg|\.png|\.gif|\.ico|\.swf|\.txt|\.iso|\.avi|\.flv|\.mp4)$ {
		gzip off;
		gzip_static off;
		expires 1h;
		proxy_cache_valid any 60m;
		proxy_cache_use_stale updating invalid_header error timeout http_404 http_500 http_502 http_503 http_504;
		proxy_cache_min_uses 0;
		proxy_cache big;
		proxy_pass http://VHOST.nginx_backend;
	}

	location / {
		proxy_cache off;
		proxy_pass http://VHOST.nginx_backend;
	}

	error_page 500 502 503 504 /50x.html;
		location = /50x.html {
		root /usr/share/nginx/www;
	}
}
