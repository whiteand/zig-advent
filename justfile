default:
    just --list

generate year day:
    mkdir ./y{{year}}
    mkdir ./y{{year}}/d{{day}}
    cp -r ./year-template/d01/part1 ./y{{year}}/d{{day}}/part1
    cp -r ./year-template/d01/part1 ./y{{year}}/d{{day}}/part2
    nu fetch.nu 20{{year}} {{day}};

run-p1 year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build && ./zig-out/bin/part1 ../input.txt
run-p1-example year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build && ./zig-out/bin/part1 ../example.txt
run-p2-example year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build && ./zig-out/bin/part1 ../example.txt

run-p2 year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build && ./zig-out/bin/part1 ../input.txt

clear:
    rm -rf ./y*/d*/part*/zig-out
    rm -rf ./y*/d*/part*/.zig-cache

