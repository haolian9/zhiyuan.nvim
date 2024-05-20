
纸鸢
---

sending system-wide notifications via libnotify

## status: experimental

it may crash nvim

## supported capatibilities:

* body
* icon
* timeout
* urgency

## prerequisites:

* linux
* a notification-daemon
* libnotify 0.8.3
* luajit 2.1.0
* zig 0.12 # for compilation
* neovim 0.10.0

## setup:

* add it to your nvim plugin manager
* `$ zig build -Doptimize=ReleaseSafe`

## use:

* `require'zhiyuan'.notify('hello', 'world')`
* or let it take over the `vim.notify`

```
vim.notify = function(msg)
    require'zhiyuan'.notify('nvim', msg)
end
```

---

thanks to:
* https://github.com/evan-goode/batnotifyd # i learnt the necessary usages of libnotify from it
* https://lucasklassmann.com/blog/2019-02-02-how-to-embeddeding-lua-in-c
