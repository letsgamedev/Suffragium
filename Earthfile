build-base:
    FROM barichello/godot-ci:4.1.2

    WORKDIR game
    COPY ./game .
    RUN mkdir -p /builds

build-linux:
    FROM +build-base
    RUN godot -v --export "Linux" /builds/suffragium

    SAVE ARTIFACT /builds/*

build-html5:
    FROM +build-base
    RUN godot -v --export "HTML5" /builds/suffragium.html

    SAVE ARTIFACT /builds/*

build-windows:
    FROM +build-base
    RUN godot -v --export "Windows" /builds/suffragium.exe

    SAVE ARTIFACT /builds/*

build:
    FROM busybox

    WORKDIR builds
    COPY builds/.gitignore .
    COPY +build-windows/ windows
    COPY +build-linux/ linux
    COPY +build-html5/ html5

    SAVE ARTIFACT . AS LOCAL ./builds