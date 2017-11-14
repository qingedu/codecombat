require('app/styles/teachers/teachers-contact-modal.sass')
ModalView = require 'views/core/ModalView'
State = require 'models/State'
TrialRequests = require 'collections/TrialRequests'
forms = require 'core/forms'
contact = require 'core/contact'

module.exports = class TeachersContactModal extends ModalView
  id: 'teachers-contact-modal'
  template: require 'templates/teachers/teachers-contact-modal'

  events:
    'submit form': 'onSubmitForm'

  initialize: (options={}) ->
    @state = new State({
      formValues: {
        name: ''
        email: ''
        licensesNeeded: ''
        message: ''
      }
      formErrors: {}
      sendingState: 'standby' # 'sending', 'sent', 'error'
    })
    @trialRequests = new TrialRequests()
    @supermodel.trackRequest @trialRequests.fetchOwn()
    @state.on 'change', @render, @

  onLoaded: ->
    trialRequest = @trialRequests.first()
    props = trialRequest?.get('properties') or {}
    name = if props.firstName and props.lastName then "#{props.firstName} #{props.lastName}" else me.get('name') ? ''
    email = me.get('email') or props.email or ''
    message = """
        你好! 我需要了解更多的课堂经验和获取课程授权来让学生开始学习课程。

        学校名称 #{props.nces_name or props.organization or ''}
        区县: #{props.nces_district or props.district or ''}
        职务: #{props.role or ''}
        电话号码: #{props.phoneNumber or ''}
      """
    @state.set('formValues', { name, email, message })
    super()

  onSubmitForm: (e) ->
    e.preventDefault()
    return if @state.get('sendingState') is 'sending'

    formValues = forms.formToObject @$el
    @state.set('formValues', formValues)

    formErrors = {}
    unless formValues.name
      formErrors.name = 'Name required.'
    unless forms.validateEmail(formValues.email)
      formErrors.email = 'Invalid email.'
    unless parseInt(formValues.licensesNeeded) > 0
      formErrors.licensesNeeded = 'Licenses needed is required.'
    unless formValues.message
      formErrors.message = 'Message required.'
    @state.set({ formErrors, formValues, sendingState: 'standby' })
    return unless _.isEmpty(formErrors)

    @state.set('sendingState', 'sending')
    data = _.extend({ country: me.get('country') }, formValues)
    contact.send({
      data
      context: @
      success: ->
        window.tracker?.trackEvent 'Teacher Contact',
          category: 'Contact',
          licensesNeeded: formValues.licensesNeeded
        @state.set({ sendingState: 'sent' })
        setTimeout(=>
          @hide?()
        , 3000)
      error: -> @state.set({ sendingState: 'error' })
    })
    
    @trigger('submit')
