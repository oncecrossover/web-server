
run run-example to try http-snoop-client/http-snoop-server, e.g.
./run-example.sh http-snoop-server
and then ./run-example.sh http-snoop-client

Usage: run-example.sh [-D<name>[=<value>] ...] <example-name>
Example: run-example.sh -Dport=8443 -Dssl http-server
         run-example.sh -Dhost=127.0.0.1 -Dport=8009 echo-client
         run-example.sh -DlogLevel=debug -Dhost=127.0.0.1 -Dport=8009 echo-client

Available examples:

  discard-client          discard-server
  echo-client             echo-server
  factorial-client        factorial-server
  file-server             http-cors-server
  http-file-server        http-helloworld-server
  http-snoop-client       http-snoop-server
  http-upload-client      http-upload-server
  websocket-client        websocket-server
  http2-client            http2-server
  http2-tiles             http2-multiplex-server
  spdy-client             spdy-server
  worldclock-client       worldclock-server
  objectecho-client       objectecho-server
  quote-client            quote-server
  redis-client            securechat-client
  securechat-server       telnet-client
  telnet-server           proxy-server
  socksproxy-server       memcache-binary-client
  stomp-client            uptime-client
  sctpecho-client         sctpecho-server
  localecho
