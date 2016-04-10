# coffeelint: disable=max_line_length

{CompositeDisposable} = require 'atom'

module.exports = SelectPasted =
  subscriptions: null
  lastRange: null

  activate: (state) ->
    console.log('select-pasted  activated')
    @lastRange = state.lastRange
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'select-pasted:paste-and-selected', ->
      return unless editor = atom.workspace.getActiveTextEditor()
      editor.pasteText select: true
      handle = editor.onDidInsertText ({range}) =>
        @lastRange = range
        handle.dispose()

    @subscriptions.add atom.commands.add 'atom-workspace', 'select-pasted:select-last-pasted': => @selectLastPasted()

    # hook paste action
    @subscriptions.add atom.commands.onWillDispatch (event) =>
      if event.type == 'core:paste'
        editor = event.target.workspace.getActiveTextEditor()
        handle = editor.onDidInsertText ({range}) =>
          console.log("save range", range)
          @lastRange = range
          handle.dispose()
    #
    # @subscriptions.add atom.workspace.observeTextEditors (editor) =>
    #   @subscriptions.add editor.onDidInsertText (event) =>
    #     @lastRange = event.range
    #     console.log(event)

  deactivate: ->
    console.log 'SelectPasted was deactivate!'
    @subscriptions.dispose()

  serialize: ->
    lastRange: @lastRange

  selectLastPasted: ->
    console.log 'SelectPasted was toggled!'

    if @lastRange and editor = atom.workspace.getActiveTextEditor()
      editor.setSelectedBufferRange(@lastRange)
