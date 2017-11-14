# /lib/emailer.coffee
config = require '../server_config'
log = require 'winston'

emailer = require("nodemailer")
fs      = require("fs")
_       = require("underscore")


module.exports.setupRoutes = (app) ->
  return

class Emailer

  # Define attachments here
#  attachments: [
#    fileName: "example.jpg"
#    filePath: "./public/images/emails/example.jpg"
#    cid: "logo@example"
#  ]

  sendAsync: (context)->
    @send(context, _.noop)

  send: (context, callback)->
#    log.debug('[nodemailer] Tried to send email with context: ', JSON.stringify(context, null, '  '))
    subject = @getSubject(context)
    to = @getTo(context)
    html = @getHtml(context.email_id, context.email_data)
    messageData =
      to: to
      from: "CodeCombat Club <#{config.smtp.username}>‍"
      subject: subject
      html: html
      generateTextFromHTML: true
    transport = @getTransport()
    transport.sendMail messageData, callback

  getTransport: ()->
    emailer.createTransport
      service: config.smtp.service
      host: config.smtp.addr
      secureConnection: true
      port: parseInt(config.smtp.port)
      auth:
        user: config.smtp.username
        pass: config.smtp.password

  getTo: (context)->
    if not context.recipient?
      to = "CodeCombat Club <#{config.smtp.username}>‍"
    else if not context.recipient.address?
      to = "CodeCombat Club <#{config.smtp.username}>‍"
    else if context.recipient.name?
      to = "#{context.recipient.name} <#{context.recipient.address}>"
    else
      to = "#{context.recipient.address}"
    to

  getSubject: (context)->
    if context.subject?
      subject = context.subject
    else if not context.email_data
      subject = '一封来自于 CodeCombat Club 的信函'
    else if context.email_data.subject?
      subject = context.email_data.subject
    else
      subject = '一封来自于 CodeCombat Club 的信函'
    subject

  getHtml: (templateName, data)->
    templatePath = "./app/assets/templates/emails/#{templateName}.html"
    templateContent = fs.readFileSync(templatePath, encoding="utf8")
    if data isnt undefined
      _.template templateContent, data, {interpolate: /\{\{(.+?)\}\}/g}
    else
      _.template templateContent, {interpolate: /\{\{(.+?)\}\}/g}

  getAttachments: (html)->
    attachments = []
    for attachment in @attachments
      attachments.push(attachment) if html.search("cid:#{attachment.cid}") > -1
    attachments


module.exports.api =
  send: (context, cb) ->

module.exports.api = new Emailer @, @
#exports = module.exports = Emailer

module.exports.templates =
  parent_subscribe_email: 'tem_parent_subscribe_email'
  coppa_deny_parent_signup: 'tem_coppa_deny_parent_signup'
  share_progress_email: 'tem_share_progress_email'
  welcome_email_user: 'tem_welcome_email_user'
  welcome_email_student: 'tem_welcome_email_student'
  verify_email: 'tem_verify_email'
  ladder_update_email: 'tem_ladder_update_email'
  patch_created: 'tem_patch_created'
  change_made_notify_watcher: 'tem_change_made_notify_watcher'
  recruiting_email: 'tem_recruiting_email'
  greed_tournament_rank: 'tem_greed_tournament_rank'
  generic_email: 'tem_generic_email'
  plain_text_email: 'tem_plain_text_email'
  next_steps_email: 'tem_next_steps_email'
  course_invite_email: 'tem_course_invite_email'
  teacher_free_trial: 'tem_teacher_free_trial'
  teacher_request_demo: 'tem_teacher_request_demo'
  password_reset: 'tem_password_reset'
  sunburst_referral: 'tem_sunburst_referral'
  share_licenses_joiner: 'tem_share_licenses_joiner'