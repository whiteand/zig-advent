default:
    just --list

generate year day:
    @(stat ./y{{year}} || mkdir ./y{{year}})
    @mkdir ./y{{year}}/d{{day}}
    @cp -r ./year-template/day/part1 ./y{{year}}/d{{day}}/part1
    @cp -r ./year-template/day/part2 ./y{{year}}/d{{day}}/part2
    @cp -r ./year-template/day/lib ./y{{year}}/d{{day}}/lib
    @echo "" > ./y{{year}}/d{{day}}/example.txt
    @nu fetch.nu 20{{year}} {{day}};
    @cd ./y{{year}}/d{{day}}/part1 && zig build --help
    @cd ./y{{year}}/d{{day}}/part2 && zig build --help

fetch year day:
    @nu fetch.nu 20{{year}} {{day}};

run-p1 year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build run -- ./src/input.txt 
run-p1-example year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build run -- ../example.txt 
run-p2-example year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build run -- ../example.txt

run-p2 year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build run -- ./src/input.txt

test year day:
    cd ./y{{year}}/d{{day}}/lib && zig build test
test-p1 year day:
    cd ./y{{year}}/d{{day}}/lib && zig build test-p1
test-p1-example year day:
    cd ./y{{year}}/d{{day}}/lib && zig build test-p1-example
test-p2 year day:
    cd ./y{{year}}/d{{day}}/lib && zig build test-p2
test-p2-example year day:
    cd ./y{{year}}/d{{day}}/lib && zig build test-p2-example

clear:
    rm -rf ./y*/d*/part*/zig-out
    rm -rf ./y*/d*/part*/.zig-cache
    rm -rf ./y*/d*/lib/zig-out
    rm -rf ./y*/d*/lib/.zig-cache

