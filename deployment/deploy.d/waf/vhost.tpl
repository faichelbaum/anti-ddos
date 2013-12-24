server {
	server_name VHOST;

	location / {
		LearningMode;
		SecRulesEnabled;
		#SecRulesDisabled;
		DeniedUrl "/RequestDenied";
		CheckRule "$SQL >= 8" BLOCK;
		CheckRule "$RFI >= 8" BLOCK;
		CheckRule "$TRAVERSAL >= 4" BLOCK;
		CheckRule "$EVADE >= 4" BLOCK;
		CheckRule "$XSS >= 8" BLOCK;
		proxy_pass http://cdn;
	}

	location /RequestDenied {
		proxy_pass http://127.0.0.1:8080;    
	}

	error_page 500 502 503 504 /50x.html;
	location = /50x.html {
		root /usr/share/nginx/www;
	}
}

