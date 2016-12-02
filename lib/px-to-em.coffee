PxToEmView = require './px-to-em-view'
{CompositeDisposable} = require 'atom'

module.exports = PxToEm =
   config:
      Unit:
         type: 'string'
         description: 'Choose a type of output unit.'
         default: 'em'
         enum: [
            'em'
            'rem'
         ],
         order: 1

      Base:
         type: 'string'
         description: 'Choose a default base.'
         default: '16',
         order: 2

      Comments:
         type: 'boolean'
         title: 'Add informative comments'
         description: 'Adds comments at the end of line with information about original size and base applied'
         default: true,
         order: 3

      Fallback:
         type: 'boolean'
         title: 'Allow fallback'
         description: 'Maintains the original line and adds the conversion to the bottom line'
         default: false,
         order: 4

   pxToEmView: null
   modalPanel: null
   subscriptions: null

   activate: ->
      atom.commands.add 'atom-workspace', 'px-to-em:toggle': => @convert()

   convert: ->
      #set Fallback value from settings.
      fallback = atom.config.get('px-to-em.Fallback')
      #store this
      plugin = this
      #set editor
      editor = atom.workspace.getActivePaneItem()
      # set container for cursors
      cursorLines = []

      #get cursors position
      editor.cursors.forEach (cursor, key) ->
         cursorLines.push(cursor.getScreenRow());
      #sort cursors position
      cursorLines.sort((a, b) -> b - a)
      #each cursors
      cursorLines.forEach (line, key) ->
         editor.selections.forEach (selection, key) ->
            # if selection is multi line
            if selection.isSingleScreenLine() == false
               firstLine = selection.getScreenRange().start.row
               lastLine = selection.getScreenRange().end.row
               line = firstLine;
               while line <= lastLine
                  plugin.replaceText(selection, line)
                  if fallback == true
                     line = line + 1
                     lastLine = lastLine + 1
                  line++
            # if selection is single line
            else
               plugin.replaceText(selection, line)
               if fallback == true
                  line = line + 1

   replaceText: (selection, line) ->
      #set editor
      editor = atom.workspace.getActivePaneItem()
      #set Comments value from settings.
      comments = atom.config.get('px-to-em.Comments')
      #set Fallback value from settings.
      fallback = atom.config.get('px-to-em.Fallback')
      #set Unit value from settings.
      unit = atom.config.get('px-to-em.Unit')
      #select lines to convert
      editor.cursors.forEach (cursor, key) ->
         cursor.setScreenPosition([line, 0])
      selection.selectToEndOfLine()
      #save line value
      text = selection.getText()
      #save origin for fallback
      fallbackValue = text
      #get init of the base
      initBase = text.search('/')
      #save the base value
      base = text.slice(initBase).slice(1)
      #get init of the px value
      values = text.match(/([0-9]+)px/gi)

      #if values exist
      if values != null
         #if not specify a base value is generated default
         if base == ''
            base = '16'
            atom.config.observe 'px-to-em.Base', (newBase) ->
               base = newBase
         #each the px values
         values.forEach (val, key) ->
            text = text.replace(val, parseInt(val)/base + unit)
            if comments == true
               if key < values.length-1
                  text = text.concat('/* ' + parseInt(val) + ' */ ').replace(/(\r\n|\n|\r)/gi, '')
               else
                  fullBase = '/'+base.replace(/(\r\n|\n|\r)/gi, '')
                  text = text.replace(/;\s/g, ';').replace(/;/g, '; ')
                  text = text.replace(fullBase, '').replace(/(\r\n|\n|\r)/gi, '') + ('/* ' + parseInt(val) + ' */')
                  text = text.replace(/\ \*\//g, '/' + base.replace(/(\r\n|\n|\r)/gi, '') + ' */')
            else
               fullBase = '/'+base.replace(/(\r\n|\n|\r)/gi, '')
               text = text.replace(/;\s/g, ';')
               text = text.replace(fullBase, '').replace(/(\r\n|\n|\r)/gi, '')

         if fallback == true
            fullBase = '/'+base.replace(/(\r\n|\n|\r)/gi, '')
            fallbackValue = fallbackValue.replace(/;\s/g, ';').replace(fullBase, '')
            text = fallbackValue.replace(/(\r\n|\n|\r)/gi, '') + '\n' + text

      selection.insertText(text)
