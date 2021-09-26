FROM golang:1.16-buster

ENV GOROOT=/usr/local/go
ENV PATH=${PATH}:/usr/local/go/bin

RUN apt update && apt install -y protobuf-compiler && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1

# pttweb
WORKDIR /srv
RUN git clone https://github.com/ptt/pttweb.git

WORKDIR /srv/pttweb
RUN go get github.com/golang/protobuf@v1.5.2 && \
    go get google.golang.org/grpc@v1.41.0 && \
    protoc --proto_path=proto --go_out=. --go_opt=Mman/man.proto="proto/man" --go-grpc_out=proto --go-grpc_opt=Mman/man.proto="github.com/ptt/pttweb/proto/man;man" man/man.proto && \
    protoc --proto_path=proto --go_out=. --go_opt=Mapi/board.proto="proto/api" --go-grpc_out=proto --go-grpc_opt=Mapi/board.proto="github.com/ptt/pttweb/proto/api;api" api/board.proto && \
    go build

COPY docs/config.json.tmpl /etc/pttweb/config.json
COPY docs/static.tmpl /srv/pttweb/static

# cmd
WORKDIR /srv/pttweb
CMD ["/srv/pttweb/pttweb", "-conf", "/etc/pttweb/config.json"]

EXPOSE 4567
