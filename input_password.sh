#!/usr/bin/expect 
set timeout 30
expect {
    "User Password"
    send "123456\r"
    "Repeat User Password"
    send "123456\r"
}
