.PHONY: build
build:
	docker run --rm --platform linux/amd64 \
		-v $(PWD):/app \
		-w /app \
		shok1122/ruby:3.2.2 ruby ./run.rb

.PHONY: run
run:
	docker run --rm -it --init --name cv-web -p 8080:80 \
		-v $(PWD)/dist:/var/www/html:ro \
		busybox:latest \
		httpd -f -v -h /var/www/html || true