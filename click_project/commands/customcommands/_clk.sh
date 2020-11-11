#!/bin/bash -eu

clk_list_to_choice () {
    echo "[$(sed -r 's-(.+)- "\1"-'| paste -s - -d,)]"
}
