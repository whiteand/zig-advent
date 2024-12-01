default:
    just --list

generate year day:
    nu fetch.nu 20{{year}} {{day}};