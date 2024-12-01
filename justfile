default:
    just --list

generate year day:
    nu fetch.nu 20{{year}} {{day}};

run-p1 year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build && ./zig-out/bin/part1 ../input.txt

