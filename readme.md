
纸鸢
---

## what for:

provides a lightweight way to send system-wide notifications

## status: experimental

may crash nvim, use at your own risk

## supported capatibilities:

* body
* icon
* timeout
* urgency

## prerequisites:

* linux
* a notification-daemon
* libnotify 0.8.1
* luajit 2.1.0
* [zig 0.10](https://ziglang.org/download) # for compiling
* neovim 0.8.0

## setup:

* add it to your nvim plugin manager
* `$ zig build -Drelease-fast`

## use:

* standalone use: `require'zhiyuan'.notify('hello', 'world')`
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
