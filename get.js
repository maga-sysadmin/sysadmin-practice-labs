// Helper for F12 DevTools Console
window.copyConfig = function(name) {
    const url = 'https://raw.githubusercontent.com/maga-sysadmin/sysadmin-practice-labs/main/' + name + '.txt';
    fetch(url)
        .then(r => r.text())
        .then(t => {
            navigator.clipboard.writeText(t);
            console.log('%c[OK] Конфигурация ' + name + ' скопирована в буфер обмена!', 'color: #10b981; font-weight: bold; font-size: 14px;');
        })
        .catch(err => console.error('[ERR]', err));
};
window.hq = () => window.copyConfig('hq');
window.br = () => window.copyConfig('br');
window.fw = () => window.copyConfig('fw');
window.rtr2 = () => window.copyConfig('rtr2');
console.log('%c[+] Готово! Команды: hq(), br(), fw(), rtr2()', 'color: #3b82f6; font-size: 13px;');
