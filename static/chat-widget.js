(function () {
  if (document.getElementById('imp-chat-root')) return;

  var API = 'https://chat-api.important.is';
  var KEY = '60801407a6271c582363b2dca48c2ea102e8196be8e66ca6';
  var msgs = [];
  var open = false;

  var root = document.createElement('div');
  root.id = 'imp-chat-root';
  root.style.cssText = 'position:fixed;bottom:28px;right:28px;z-index:9999;font-family:system-ui,-apple-system,sans-serif';
  document.body.appendChild(root);

  var panel = document.createElement('div');
  panel.style.cssText = 'display:none;position:absolute;bottom:72px;right:0;width:380px;height:500px;background:#fff;border-radius:16px;box-shadow:0 8px 40px rgba(0,0,0,.18);display:flex;flex-direction:column;overflow:hidden;border:1px solid #e2e8f0';
  panel.style.display = 'none';

  panel.innerHTML = '<div style="padding:14px 18px;background:#2563eb;color:#fff;display:flex;align-items:center;justify-content:space-between;flex-shrink:0">'
    + '<span style="font-weight:600;font-size:15px">💬 Asystent finansowy</span>'
    + '<button id="imp-chat-close" style="background:none;border:none;color:#fff;cursor:pointer;font-size:22px;line-height:1;padding:0">×</button>'
    + '</div>'
    + '<div id="imp-chat-msgs" style="flex:1;overflow-y:auto;padding:16px;display:flex;flex-direction:column;gap:10px">'
    + '<div style="background:#f1f5f9;border-radius:12px;padding:10px 14px;font-size:13.5px;color:#475569;max-width:90%">Cześć! Pytaj o przychody, marże, zaległości, klientów, zespół — mam dostęp do aktualnych danych.</div>'
    + '</div>'
    + '<div style="padding:12px;border-top:1px solid #e2e8f0;display:flex;gap:8px;flex-shrink:0">'
    + '<input id="imp-chat-input" type="text" placeholder="Np. jaki był przychód w maju?" style="flex:1;padding:9px 13px;border:1px solid #cbd5e1;border-radius:8px;font-size:13.5px;outline:none">'
    + '<button id="imp-chat-send" style="padding:9px 16px;background:#2563eb;color:#fff;border:none;border-radius:8px;cursor:pointer;font-size:15px">→</button>'
    + '</div>';

  root.appendChild(panel);

  var btn = document.createElement('button');
  btn.id = 'imp-chat-btn';
  btn.title = 'Asystent finansowy';
  btn.style.cssText = 'width:56px;height:56px;border-radius:50%;background:#2563eb;color:#fff;border:none;cursor:pointer;font-size:22px;box-shadow:0 4px 16px rgba(37,99,235,.45)';
  btn.textContent = '💬';
  root.appendChild(btn);

  function toggle() {
    open = !open;
    panel.style.display = open ? 'flex' : 'none';
    btn.textContent = open ? '✕' : '💬';
    if (open) setTimeout(function () { document.getElementById('imp-chat-input').focus(); }, 80);
  }

  function addMsg(role, text) {
    var el = document.createElement('div');
    var isUser = role === 'user';
    el.style.cssText = 'border-radius:12px;padding:10px 14px;font-size:13.5px;max-width:88%;white-space:pre-wrap;line-height:1.5;'
      + (isUser ? 'background:#2563eb;color:#fff;align-self:flex-end' : 'background:#f1f5f9;color:#1e293b');
    el.textContent = text;
    var msgsEl = document.getElementById('imp-chat-msgs');
    msgsEl.appendChild(el);
    msgsEl.scrollTop = msgsEl.scrollHeight;
    if (role !== 'loading') msgs.push({ role: role, content: text });
    return el;
  }

  function send() {
    var input = document.getElementById('imp-chat-input');
    var text = input.value.trim();
    if (!text) return;
    input.value = '';
    input.disabled = true;
    document.getElementById('imp-chat-send').disabled = true;
    addMsg('user', text);
    var loading = addMsg('loading', 'Analizuję...');
    loading.style.color = '#94a3b8';

    fetch(API + '/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-api-key': KEY },
      body: JSON.stringify({ messages: msgs })
    })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        loading.remove();
        addMsg('assistant', d.answer || d.error || 'Błąd odpowiedzi');
      })
      .catch(function () {
        loading.remove();
        addMsg('assistant', 'Błąd połączenia z API.');
      })
      .finally(function () {
        input.disabled = false;
        document.getElementById('imp-chat-send').disabled = false;
        input.focus();
      });
  }

  btn.addEventListener('click', toggle);
  document.getElementById('imp-chat-close').addEventListener('click', toggle);
  document.getElementById('imp-chat-send').addEventListener('click', send);
  document.getElementById('imp-chat-input').addEventListener('keydown', function (e) {
    if (e.key === 'Enter') send();
  });
})();
