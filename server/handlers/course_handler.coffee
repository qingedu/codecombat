Session = require './../models/LevelSession'
User = require '../models/User'
SessionHandler = require './level_session_handler'
Feedback = require './../models/LevelFeedback'
Handler = require '../commons/Handler'
mongoose = require 'mongoose'
async = require 'async'
utils = require '../lib/utils'
log = require 'winston'
Campaign = require '../models/Campaign'
Course = require  '../models/Course'
CourseInstance = require '../models/CourseInstance'
Classroom = require '../models/Classroom'

CourseHandler = class CourseHandler extends Handler
  modelClass: Course
  jsonSchema: require '../../app/schemas/models/course.schema'
  editableProperties: [
    'campaignID',
    'concepts',
    'description',
    'duration',
    'pricePerSeat',
    'free',
    'screenshot',
    'adminOnly',
    'releasePhase',
    'i18n',
    'i18nCoverage'
  ]

  hasAccess: (req) ->
    return true if req.method is 'GET'
    req.method in ['GET', 'POST'] or req.user?.isAdmin()

  makeNewInstance: (req) ->
    instance = super(req)
    instance.set 'name', req.body.name
    instance.set 'free', false
    instance.set 'releasePhase', 'beta'
    instance.set 'duration', 1
    instance.set 'campaignID', '55b29efd1cd6abe8ce07db0d'
    instance.set 'pricePerSeat', 0
    instance

module.exports = new CourseHandler()