function suspendqs --wraps='qs -c noctalia-shell ipc call sessionMenu lockAndSuspend' --description 'alias suspendqs qs -c noctalia-shell ipc call sessionMenu lockAndSuspend'
    qs -c noctalia-shell ipc call sessionMenu lockAndSuspend $argv
end
