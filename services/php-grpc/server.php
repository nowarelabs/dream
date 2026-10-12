<?php

require __DIR__ . '/vendor/autoload.php';

class EchoService extends \Echo\EchoStub
{
    public function Say(
        \Echo\EchoRequest $request,
        \Grpc\ServerContext $context
    ): ?\Echo\EchoReply {
        $reply = new \Echo\EchoReply();
        $reply->setMessage('echo: ' . $request->getMessage());
        return $reply;
    }
}

$port = getenv('PORT') ?: '50060';

$server = new \Grpc\RpcServer();
$server->addHttp2Port('0.0.0.0:' . $port);
$server->handle(new EchoService());
echo 'php-grpc listening on 0.0.0.0:' . $port . PHP_EOL;
$server->run();
