local function showReportDetail(report)
    lib.registerContext({
        id = ('qbx_adminmenu_reports_menu_%s'):format(report.id),
        title = ('Denúncia #%s | De: %s'):format(report.id, report.senderName),
        menu = 'qbx_adminmenu_reports_menu',
        options = {
            { title = 'Ver Mensagem', icon = 'fas fa-message', onSelect = function()
                lib.alertDialog({
                    header = ('Denúncia #%s | De: %s'):format(report.id, report.senderName),
                    content = ('Mensagem: %s'):format(report.message),
                    centered = true,
                    cancel = false,
                    size = 'lg',
                    labels = { confirm = 'Fechar' },
                })
                showReportDetail(report)
            end },
            { title = 'Responder', icon = 'fas fa-reply', onSelect = function()
                local dialog = lib.inputDialog(('Denúncia #%s | De: %s'):format(report.id, report.senderName), {
                    { type = 'input', label = 'Resposta' },
                })

                if not dialog or not dialog[1] or dialog[1] == '' then
                    exports.qbx_core:Notify(locale('error.no_report_reply'), 'error')
                else
                    TriggerServerEvent('qbx_admin:server:sendReply', report, dialog[1])
                end

                showReportDetail(report)
            end },
            { title = 'Encerrar Denúncia', icon = 'fas fa-trash', onSelect = function()
                TriggerServerEvent('qbx_admin:server:deleteReport', report)
                GenerateReportMenu()
            end },
            { title = ('Atendido por: %s'):format(report.claimed), readOnly = true },
            { title = ('ID da Denúncia: %s'):format(report.id), readOnly = true },
            { title = ('ID do Remetente: %s'):format(report.senderId), readOnly = true },
            { title = ('Nome do Remetente: %s'):format(report.senderName), readOnly = true },
        },
    })
    lib.showContext(('qbx_adminmenu_reports_menu_%s'):format(report.id))
end

function GenerateReportMenu()
    local reports = lib.callback.await('qbx_admin:server:getReports', false)

    if not reports or #reports < 1 then
        exports.qbx_core:Notify(locale('error.no_reports'), 'error')
        ShowMainMenu()
        return
    end

    exports.qbx_core:Notify(locale('success.report_load'):format(#reports), 'success')

    local reportsList = {}
    for i = 1, #reports do
        reportsList[i] = {
            title = locale('report_options.label1'):format(reports[i].id, reports[i].senderName),
            description = locale('report_options.desc1'),
            icon = 'fas fa-flag',
            arrow = true,
            onSelect = function() showReportDetail(reports[i]) end,
        }
    end

    lib.registerContext({
        id = 'qbx_adminmenu_reports_menu',
        title = locale('title.reports_menu'),
        menu = 'qbx_adminmenu_main_menu',
        options = reportsList,
    })
    lib.showContext('qbx_adminmenu_reports_menu')
end
