<?php

require __DIR__ . '/../vendor/autoload.php';

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

$app = AppFactory::create();

$app->get('/', function (Request $request, Response $response) {
    $response->getBody()->write(json_encode([
        'service' => 'php-slim',
        'framework' => 'slim',
    ]));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->run();
