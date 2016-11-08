PxToEmView = require './px-to-em-view'
{CompositeDisposable} = require 'atom'

module.exports = PxToEm =
   config:
     Comments:
       title: 'Enable Comments?'
       description: 'e.g. margin: 1.25em 0.75em 0.3125em 0.875em; /&#42; 20/16 &#42;/ /&#42; 12/16 &#42;/ /&#42; 5/16 &#42;/ /&#42; 14/16 &#42;/'
       type: 'boolean'
       default: true
     Fallback:
       title: 'Leave fallback?'
       description: 'e.g.<br/>margin-top: 16px;<br/>margin-top: 1rem;'
       type: 'boolean'
       default: false
     Unit:
       type: 'string'
       description: 'Choose a type of output unit.'
       default: 'em'
       enum: [
         'em'
         'rem'
       ]

   pxToEmView: null
   modalPanel: null
   subscriptions: null

   activate: ->
      atom.commands.add 'atom-workspace', 'px-to-em:toggle': => @convert()

   convert: ->

      #set Comments value from settings.
      comments = atom.config.get('px-to-em.Comments')
      #set Fallback value from settings.
      fallback = atom.config.get('px-to-em.Fallback')
      #set Unit value from settings.
      unit     = atom.config.get('px-to-em.Unit')

      editor = atom.workspace.getActivePaneItem()
      #select current line
      selection = editor.selectLinesContainingCursors()
      #get line value
      original = editor.getLastSelection()
      #save line value
      text = original.getText().replace(' /', '/')
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
            text = text + ' '
         #each the px values
         values.forEach (val, key) ->
            text = text.replace(val, parseInt(val)/base + unit)
            if comments == true
              if key < values.length-1
                text = text.concat('/* ' + parseInt(val) + ' */ ').replace(/(\r\n|\n|\r)/gi, '')
              else
                fullBase = '/'+base.replace(/(\r\n|\n|\r)/gi, '')
                text = text.replace(fullBase, ' ').replace(/(\r\n|\n|\r)/gi, '') + ('/* ' + parseInt(val) + ' */')
                text = text.replace(/\ \*\//g, '/' + base.replace(/(\r\n|\n|\r)/gi, '') + ' */')
                text = text + '\r\n'

        if fallback == true
          text = fallbackValue + text

      original.insertText(text)
