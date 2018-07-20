default:
	docker run -d  --name caddy -p 8080:8080 -v /INSTALL:/data caddy
build:
	docker build -t caddy -f Dockerfile .
build-proxy:
	docker build -t thikade/caddy:fwd-proxy -f Dockerfile.proxy .
proxy:
	docker run -d  --name caddyproxy -p 7890:8080 -v thikade/caddy:fwd-proxy

