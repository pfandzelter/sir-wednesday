.PHONY: deploy clean

deploy: frog.zip main.tf init.done
	terraform apply
	touch $@

init.done:
	terraform init
	touch $@

frog.zip: frog
	chmod +x frog
	zip -j $@ $<

frog: main.go
	go get .
	GOOS=linux GOARCH=amd64 go build -ldflags="-d -s -w" -o $@

clean:
	terraform destroy
	rm -f init.done deploy.done hello.zip hello