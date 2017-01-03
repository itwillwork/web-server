# Веб-сервер на Erlang

Задание:
  
Разработать веб-сервер для отдачи статики с диска. Язык программирования и технология многопоточной обработки соединений выбрать самостоятельно. Разрешается использовать библиотеки помогающие реализовать асинхронную обработку соединений (libevent/libev, netty и им подобные), запрещается использовать библиотеки реализующие мультипоточную обработку или какую-либо часть обработки HTTP.
Провести нагрузочное тестирование, проверку стабильности и корректности работы.

Веб-сервер должен уметь:

- Масштабироваться на заданное количество CPU (либо использовать все)
- Отвечать на GET-запросы и HEAD-запросы
- Возвращать index.html как индекс директории
- Возвращать файлы по произвольному пути в DOCUMENT_ROOT
- Отвечать следующими заголовками для успешных GET-запросов: Date, Server, Content-Length, Content-Type, Connection
- Корректный Content-Type для: .html, .css, .js, .jpg, .jpeg, .png, .gif, .swf
- Понимать пробелы и %XX в именах файлов
- Стабильно работать
- Иметь производительность сопоставимую с nginx (разница не больше порядка)