;; Copyright (c) 2019 Shellyl_N
;; license: MIT
;; https://github.com/shellyln


;; Report configurations
($last ($let records $data)

    ;; Set status to show
    ($let status-list ($list
        (# (value "Backlog")
           (caption "🛌 Backlog")
           (class "status-backlog") )
        (# (value "ToDo")
           (caption "📯 ToDo")
           (class "status-todo") )
        (# (value "InProgress")
           (caption "⛏ InProgress")
           (class "status-inprogress") )
        (# (value "Staging")
           (caption "📦 Staging")
           (class "status-staging") )
        (# (value "Done")(done)
           (caption "🎉 Done")
           (class "status-done") )))

    ;; Set teams or stories to show
    ($let team-or-story-list ($list
        (# (value "Team A")
           (caption "🐆 Team A")
           (class "team-or-story-team-a") )
        (# (value "Team B")
           (caption "🦃 Team B")
           (class "team-or-story-team-b") )
        (# (value "Team C")
           (caption "🐍 Team C")
           (class "team-or-story-team-c") )))

    ;; Set your kintone environment domain and app id
    ($let url-base "https://?????????.cybozu.com/k/")
    ($let app-id   15)

    ($let api-url-base ($concat url-base "v1/"))
    ($let record-url-base ($concat url-base app-id "/"))

    ;; Report styles
    ($let reportStyles """$concat
    body {
        width: 100%;
        height: 100%;
        background-color: #fafafa;
        font-family: helvetica, arial, 'hiragino kaku gothic pro', meiryo, 'ms pgothic', sans-serif;
    }
    table.board {
        width: calc(100% - 30px);
        height: 100%;
        margin: 15px;
        border: solid 1px #000;
        border-collapse: collapse;
    }
    table.board thead th {
        position: sticky;
        top: 0;
        z-index: 2;
        background-color: white;
    }
    table.board thead th a {
        color: inherit;
        text-decoration: none;
    }
    table.board th:first-child {
        position: sticky;
        left: 0;
        z-index: 1;
        background-color: white;
    }
    table.board th {
        border: solid 1px #000;
        border-collapse: collapse;
        padding: 5px;
    }
    table.board td {
        border: solid 1px #000;
        border-collapse: collapse;
        padding: 5px;
        vertical-align: middle;
    }
    table.board thead th.status-backlog {
        background-color: #f8f8f8;
    }
    table.board td.status-backlog {
        background-color: #efefef;
    }
    table.board thead th.status-done {
        background-color: #f8f8f8;
    }
    table.board td.status-done {
        background-color: #efefef;
    }
    .sticky-wrap {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        align-items: flex-start;
        width: 100%;
        height: 100%;
    }
    .sticky-note {
        position: relative;
        display: block;
        background-color: #fff5a3;
        filter: drop-shadow(5px 5px 2px #888);
        width: 150px;
        min-height: 80px;
        height: auto;
        margin: 5px;
        padding: 5px;
        word-wrap: break-word;
        transform: rotate(-0.25deg);
    }
    .sticky-link {
        display: block;
    }
    .sticky-link:nth-of-type(2n) .sticky-note {
        transform: rotate(0.15deg);
    }
    .sticky-link:nth-of-type(3n) .sticky-note {
        transform: rotate(0.65deg);
    }
    .sticky-link:nth-of-type(5n) .sticky-note {
        transform: rotate(-0.65deg);
    }
    .sticky-link .sticky-note:hover {
        filter: drop-shadow(7px 7px 2px #888);
        transform: rotate(-3deg);
    }
    .team-or-story-team-b .sticky-note {
        background-color: #dbedff;
    }
    .status-done .sticky-note {
        background-color: #cfffcc;
    }
    .sticky-note.expired {
        background-color: #ffafaf;
    }
    .sticky-note h1,h2,h3,h4,h5,h6,p {
        font-size: 85%;
    }
    .sticky-wrap a.sticky-link {
        color: inherit;
        text-decoration: none;
    }
    .sticky-note .marked {
        position: absolute;
        top: 0px;
        right: 0px;
        font-size: 95%;
    }
    .sticky-note .due-date {
        position: absolute;
        bottom: 0px;
        right: 0px;
        font-size: 70%;
    }
    .sticky-note.expired .due-date {
        color: red;
        font-weight: bold;
    }
    """)

    ;; Report script
    ($let reportScript """$concat
    async function updateStatus(target, el) {
        try {
            const resp = await fetch('%%%($concat api-url-base "record.json")', {
                method: 'PUT',
                credentials: 'include',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'Content-Type': 'application/json; charset=utf-8',
                },
                body: JSON.stringify({
                    app: '%%%($get app-id)',
                    id: String(el.attributes['data-record-id'].value),
                    record: {
                        'team_or_story': {
                            'value': target.attributes['data-team-or-story'].value,
                        },
                        'status': {
                            'value': target.attributes['data-status'].value,
                        },
                    },
                    '__REQUEST_TOKEN__': '%%%($get $REQUEST-TOKEN)',
                }),
            });
            if (resp.ok) {
                console.log(JSON.stringify(await resp.json()));
            } else {
                console.log(resp.statusText);
                throw new Error('Failed to update record: ' + resp.statusText);
            }
        } catch (e) {
            console.log(e);
            throw new Error('Failed to update record: ' + e.message);
        }
    }
    function onStickyDragStart(ev) {
        ev.dataTransfer.setData('elId', ev.target.id);
    }
    function onStickyDragOver(ev) {
        ev.preventDefault();
    }
    function onStickyDrop(ev) {
        (async () => {
            try {
                const elId = ev.dataTransfer.getData('elId');
                const el = document.getElementById(elId);
                const target = ev.currentTarget;
                await updateStatus(target, el);
                target.appendChild(el);
            } catch (e) {
                alert(e.message);
            }
        })();
        ev.preventDefault();
    }
    """)
    nil)


;; Components
($last
    ($defun $today () ($datetime ...($slice 0 3 ($datetime-to-components-lc ($now)))))
    ($defun Sticky (team-or-story status)
        (div (@ (class ("sticky-wrap"
                        ($if ::team-or-story:class ::team-or-story:class nil)
                        ($if ::status:class ::status:class nil) ))
                (data-team-or-story ::team-or-story:value)
                (data-status ::status:value)
                (ondragover "onStickyDragOver(event)")
                (ondrop     "onStickyDrop(event)") )
            ($=for ($filter records (|-> (x) use (team-or-story status)
                                        ($and (=== ::team-or-story:value ::x:team_or_story:value)
                                              (=== ::status:value        ::x:status:value) )))
                ($last ($let expired
                            ($and ($not ::status:done) ::$data:due_date:value
                                  (< ($datetime-from-iso ::$data:due_date:value) ($today)) )) nil)
                (a (@ (class "sticky-link")
                      (href ($concat record-url-base "show#record=" ::$data:$id:value))
                      (target "_blank")
                      (id ($eval ($gensym)))
                      (data-record-id ::$data:$id:value)
                      (draggable "true")
                      (ondragstart "onStickyDragStart(event)")   )
                    (div (@ (class ("sticky-note" ($if expired "expired"))) )
                        (Markdown ::$data:description:value)
                        ($=if ::$data:barcode:value
                            (Qr (@ (cellSize 0.45) (data ::$data:barcode:value))) )
                        ($=if ($find ::$data:flags:value (-> (x) (=== x "Marked"))) (div (@ (class "marked")) 📍))
                        ($=if ::$data:due_date:value
                            (div (@ (class "due-date")) ($if expired 🔥 ⏳) ::$data:due_date:value) ))))))
    nil)


;; Report body
(Html5
    (head (title "KanbanBoard")
          (meta (@ (charset "UTF-8")))
          (NormalizeCss)
        (style (@ (dangerouslySetInnerHTML reportStyles))) )
    (body
        (table (@ (class "board"))
            (thead (tr
                (th (a (@ (href ($concat record-url-base "edit"))
                                (target "_blank") ) ➕ ))
                ($=for status-list ($last ($let status $data) nil) (th
                                (@ (class (($if ::status:class ::status:class nil) )))
                    ($or ::$data:caption ::$data:value) ))))
            (tbody ($=for team-or-story-list ($last ($let team-or-story $data) nil)
                (tr (th (@ (class (($if ::team-or-story:class ::team-or-story:class nil))))
                        ($or ::$data:caption ::$data:value) )
                    ($=for status-list ($last ($let status $data) nil)
                        (td (@ (class (($if ::team-or-story:class ::team-or-story:class nil)
                                       ($if ::status:class ::status:class nil) )))
                        (Sticky team-or-story $data))) ))))
        (script (@ (dangerouslySetInnerHTML reportScript))) ))

