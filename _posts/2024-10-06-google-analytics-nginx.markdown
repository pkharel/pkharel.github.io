---
layout: post
title:  "Integrate Google Analytics with NGINX"
tags:
  - google analytics 
  - nginx 
  - jellyfin 
---

## Google Analytics 
[Google Analytics](https://analytics.google.com) let you gather info about the
traffic to your site. Once you create an account, you get assigned a
`tag`. There are instructions on the GA site on how to enable analytics but it
typically typically involves adding some HTML/Javascript code to the main page
of your site.

```
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-XXXXX');
</script>
```

Once you insert this code to the main page of your site, you should start seeing
data on Google Analytics. For testing, you might need to disable any ad blockers
as those might block the GA scripts.

## Google Analytics via NGINX injection
Some servers or static site generators (like Jekyll) support Google Analytics.
For example, for Jekyll, you just need to add your Google Analytics tag to your
config file and it will insert the GA code into all the pages that it
generates.

Some servers however don't support Google Analytics. Since I'm already using
NGINX reverse proxy, I wanted to see if I could try and inject the Google
Analytics code so I could get traffic info for servers that don't support Google
Analytics like Jellyfin.

NGINX, if built with `--with-http_sub_module` supports a
[`sub_filter`](https://nginx.org/en/docs/http/ngx_http_sub_module.html) command
that can replace a string with another. We can use this to replace an HTML tag
like `</head>` with the GA code.

```
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    ...
    # Google analytics
    sub_filter_types text/html;
    sub_filter '</head>' '<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX"></script>
    	              <script>
    		        window.dataLayer = window.dataLayer || [];
                            function gtag(){dataLayer.push(arguments);}
                            gtag(\'js\', new Date());
    
                            gtag(\'config\', \'G-XXXXXXX\');
    		      </script></head>';
    sub_filter_once off;
    ...
    location / {
        ...
	      proxy_set_header Accept-Encoding ""; 
```

The snippet of code above should replace `</head>` with the GA code + the
`</head>` tag. We only want to do the replacement on `text/html` MIME types. You
can then do a `systemct reload nginx`. 
