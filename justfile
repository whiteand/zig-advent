default:
    just --list

generate year day:
    # mkdir ./y{{year}}
    @mkdir ./y{{year}}/d{{day}}
    @cp -r ./year-template/d01/part1 ./y{{year}}/d{{day}}/part1
    @cp -r ./year-template/d01/part1 ./y{{year}}/d{{day}}/part2
    @echo "" > ./y{{year}}/d{{day}}/example.txt
    @nu fetch.nu 20{{year}} {{day}};
    @cd ./y{{year}}/d{{day}}/part1 && zig build --help
    @cd ./y{{year}}/d{{day}}/part2 && zig build --help

run-p1 year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build run -- ./src/input.txt 
run-p1-example year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build run -- ../example.txt 
run-p2-example year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build run -- ../example.txt

run-p2 year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build run -- ./src/input.txt

test-p1 year day:
    cd ./y{{year}}/d{{day}}/part1 && zig build test
    
test-p2 year day:
    cd ./y{{year}}/d{{day}}/part2 && zig build test

test year day:
    just test-p1 {{year}} {{day}}
    just test-p2 {{year}} {{day}}


clear:
    rm -rf ./y*/d*/part*/zig-out
    rm -rf ./y*/d*/part*/.zig-cache

