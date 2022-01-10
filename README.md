# Fiver

Dashboard and management console for [ActiveJob](https://guides.rubyonrails.org/active_job_basics.html)'s [`:advanced_sneakers` adapter](https://github.com/veeqo/advanced-sneakers-activejob) (built on top of [Sneakers](https://github.com/jondot/sneakers)).

Run as a standalone application using a pre-built _Docker_ image or mount as a _Rails_ engine inside your application.

Your _RabbitMQ_ instance *must* have the [`management` plugin](https://www.rabbitmq.com/management.html) enabled.

## Configuration

The following two environment variables should be defined:

* `RABBITMQ_URL`: The _AMQP_ URL used to connect to your _RabbitMQ_ instance, e.g.: `amqp://rabbitmq.example.com:5672`
* `RABBITMQ_MANAGEMENT_URL`: The _HTTP(S)_ URL used to connect to your _RabbitMQ_ management instance, e.g.: `https://rabbitmq.example.com:15672`

## License

[MIT License](LICENSE)
