{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: "PlantUML"
  scopeName: "source.plantuml"
  fileTypes: [ "puml", "plantuml", "txt" ]

  macros:
    # for demonstartion purpose, how to use regexes as macros
    hexdigit: /[0-9a-fA-F]/
    entityName: /[\w\u0080-\uFFFF]+/
    entityQuoted: /"[^"]+"/
    stringQuoted: /{entityQuoted}/

    en: "entity.name"
    pd: "punctuation.definition"
    ps: "punctuation.separator"
    ii: "invalid.illegal"

  firstLineMatch: '^@startuml'
  patterns: [
    {
      name: 'meta.source.block'
      begin: '^@startuml'
      beginCaptures:
        '0': { name: 'punctuation.section.source.begin' }
      contentName: 'source'
      end: '^@enduml'
      endCaptures:
        '0': { name: 'punctuation.section.sourec.end' }
      patterns: [
        include: '#plantuml'
      ]
    }
  ]
  'repository':
    'plantuml':
      patterns: [
        {
          include: '#comments'
        }
        {
          name: 'meta.skinparam'
          match: /^\s*(skinparam)\s+(\S+)\s+(.*)$/
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.tag' }
            '3': { name: 'constant.other' }
        }
        {
          name: 'meta.title'
          match: /^\s*(title)\s+(\S.*)$/
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'string.unquoted' }
        }
        {
          name: 'meta.legend.block'
          begin: /^\s*(legend)(?:\s+(left|right|center))?\s*$/
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'variable.language' }
          end: /^\s*(endlegend)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          contentName: 'string.unquoted'
        }
        {
          name: 'meta.newpage'
          match: /^\s*(newpage)\s*$/
          captures:
            '1': { name: 'keyword.control' }
        }
        {
          name: 'meta.note.block'
          begin: ///
              ^\s*
              ([hr]?note)\s*
              (?:
                \s+((?:left|right)(?:\s+of)|over)
                (?:\s+
                  ([\w\u0080-\uFFFF]+)
                  (\s*,\s*([\w\u0080-\uFFFF]+))*
                )?
                (?:\s+(\#\w+))?
              )?\s*
              $
              ///
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'variable.language' }
            '3': { name: 'entity.type.name' }
            '5': { name: 'entity.type.name' }
            '6': { name: 'constant.other.color' }
          end: /^\s*(end\s+[hr]?note|end[hr]note)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          contentName: 'string.unquoted'
        }
        {
          name: 'meta.note.line'
          match: ///^
              ([hr]?note)\s*
              (?:
                \s+(left|right|left\s+of|right\s+of|over)
                (?:\s+
                  ([\w\u0080-\uFFFF]+)
                  (\s*,\s*([\w\u0080-\uFFFF]+))*
                )?
                (?:\s+(\#\w+))?
              )?\s*
              (:)\s*(\S.*)\s*
              $
              ///
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'variable.language' }
            '3': { name: 'entity.type.name' }
            '5': { name: 'entity.type.name' }
            '6': { name: 'constant.other.color' }
            '7': { name: 'keyword.operator' }
            '8': { name: 'string.unquoted' }
        }
        {
          include: '#sequence_diagram'
        }
        {
          include: '#usecase_diagram'
        }
        {
          include: '#class_diagram'
        }
        {
          include: '#activity_diagram'
        }
        {
          include: '#component_diagram'
        }
        {
          include: '#state_diagram'
        }
        {
          include: "#object_diagram"
        }

        # {
        #   # TODO: c-like macro
        #   match: '^\\s*(!(?:define|endif|ifdef|ifndef|include|undef))\\b.*$'
        #   captures:
        #     '1':
        #       name: 'keyword.control.import'
        #   name: 'meta.preprocessor'
        # }
        # {
        #   # TODO: escaped character
        #   match: '(")([^"]*)(")'
        #   captures:
        #     '1':
        #       name: 'punctuation.definition.string.begin'
        #     '3':
        #       name: 'punctuation.definition.string.end'
        #   name: 'string.quoted.double'
        # }
      ]
    'comments':
      patterns: [
        {
          begin: /(^[ \t]+)?(?=\')/
          beginCaptures:
            '1': { name: 'punctuation.whitespace.comment.leading' }
          end: /(?!\G)/
          patterns: [
            {
              name: 'comment.line.singlequote'
              begin: /'/
              beginCaptures:
                '0': { name: 'punctuation.definition.comment' }
              end: /\n/
            }
          ]
        }
        {
          name: 'comment.block'
          begin: /\/'/
          beginCaptures:
            '0': { name: 'punctuation.definition.comment.begin' }
          end: /'\//
          endCaptures:
            '0': { name: 'punctuation.definition.comment.end' }
        }

      ]
    'sequence_diagram':
      patterns: [
        {
          name: 'meta.sequence.driver'
          match: ///
              ^\s*
              (==+)\s*
              ([^=]+)\s*
              (==+)\s*
              $///
          captures:
            '1': { name: 'keyword.operator' }
            '2': { name: 'string.unquoted' }
            '3': { name: 'keyword.operator' }
        }
        {
          name: 'meta.autonumber'
          match: ///^\s*
              (autonumber)
              \s+(?:(\d+)|({stringQuoted}))?
              \s+(?:(\d+)|({stringQuoted}))?
              \s+(?:({stringQuoted}))?
              \s*$///
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'constant.numeric' }
            '3': { name: 'string.quoted.double' }
            '4': { name: 'constant.numeric' }
            '5': { name: 'string.quoted.double' }
            '6': { name: 'string.quoted.double' }
        }
        {
          name: 'meta.sequence.alt'
          begin: ///^\s*
              (alt)
              (?:\s+(.*))?\s*
              $///
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'string.unquoted' }
          end: /^\s*(end)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          patterns: [
            {
              match: ///^\s*
                  (else)
                  (?:\s+(.*))?\s*
                  $///
              captures:
                '1': { name: 'keyword.control' }
                '2': { name: 'string.unquoted' }
            }
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.box'
          begin: /^\s*(box)\s+(.*)\s*$/
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'string.quoted' }
          end: /^\s*(end\s+box)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.loop'
          begin: /^\s*(loop)(?:\s+(.*)\s+(times))?\s*$/
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'variable.language' }
            '3': { name: 'keyword.control' }
          end: /^\s*(end(?:\s+loop)?)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.groupalt'
          begin: ///^\s*
                (opt|loop|par|break|critical)
                (?:\s+(.*))?
                \s*$///
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'string.unquoted' }
          end: /^\s*(end(?:\s+\1)?)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.group'
          begin: /^\s*(group)\s+(.*)\s*$/
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'string.unquoted' }
          end: /^\s*(end(?:\s+\1)?)\s*$/
          endCaptures:
            '1': { name: 'keyword.control' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.declaring'
          match: ///^\s*
              (
                create(?:\s+(?:actor|boundary|control|entity|database|participant))?
                |
                (?:actor|boundary|control|entity|database|participant)
              )\s+
              (?:([\w\u0080-\uFFFF]+|"[^"]+")\s+(as))?
              \s+([\w\u0080-\uFFFF]+|"[^"]+")
              (?:\s+(<<)\s*
                (?:\((.),(\#?\w+)\))?
                (.*)
              \s*(>>))?
              (?:\s+(\#\w+))?
              \s*$///
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.type' }
            '3': { name: 'keyword.control' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'punctuation.definition.stereotype.begin' }
            '6': { name: 'constant.character' }
            '7': { name: 'constant.other.color' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: 'punctuation.definition.stereotype.end' }
            '10': { name: 'constant.other.color' }
        }
        {
          name: 'meta.sequence.activate'
          match: /^\s*((?:de)?activate)\s+(.*)\s*$/
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.type' }
        }
        {
          name: 'meta.sequence.arrow'
          match: ///
                ^\s*
                (?:
                  ([\w\u0080-\uFFFF]+|"[^"]+")\s*
                  |
                  (\[)
                )
                (
                  (?:[ox])?
                  (?:<<?|\\\\?|//?)?
                  -(?:\[(\#\w+)\])?-?
                  (?:>>?|\\\\?|//?)?
                  (?:[ox](?=\]|\s))?
                )
                (?:
                  (\])
                  |
                  \s*([\w\u0080-\uFFFF]+|"[^"]+")
                  (?:\s+(as)\s+([\w\u0080-\uFFFF]+|"[^"]+"))?
                )\s*
                (:)\s*
                (.*)$
                ///
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'meta.class.bracket.left' }
            '3': { name: 'meta.class.arrow' }
            '4': { name: 'constant.other.color' }
            '5': { name: 'meta.class.bracket.right' }
            '6': { name: 'entity.name.type' }
            '7': { name: 'keyword.control' }
            '8': { name: 'entity.name.type' }
            '9': { name: 'constant.other.color' }
            '10': { name: 'string.unquoted' }
        }
      ]
    # TODO: implement usecase_diagram
    'usecase_diagram':
      patterns: [
      ]
    'class_diagram':
      patterns: [
        {
          name: 'meta.class.arrow'
          match: ///^\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s*
              ("[^"]*")?\s*
              (
                  (?:<\|?|\*|(?=<\s)o)?
                  (?:-+|\.+)
                  (?:\|?>|\*|o(?=\s))?
              )\s*
              ("[^"]*")?\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s*
              (?:(:)\s*(<|>)?\s*([^<>]*)\s*(<|>)?\s*)?\s*
              $///
          captures:
            '1': { name: 'entity.name.type' }
            '2': { name: 'string.qoted.double' }
            '3': { name: 'keyword.operator' }
            '4': { name: 'string.qoted.double' }
            '5': { name: 'entity.name.type' }
            '6': { name: 'punctuation.definition.description' }
            '7': { name: 'keyword.operator' }
            '8': { name: 'string.unquoted' }
            '9': { name: 'keyword.operator' }
        }
        {
          name: 'meta.class.declaring'
          match: ///^\s*
              (class|abstract(?:\s+class)?|interface|annotation|enum)\s+
              ((?:[\w\u0080-\uFFFF]+|"[^"]+")(?:<[^>]+>)?)
              (?:\s+(as)\s+([\w\u0080-\uFFFF]+|"[^"]+"))?\s*
              (?:\s+(<<)\s*
                  (?:\((.),(\#?\w+)\))?\s*
                  ([^<>\(\)]+)?\s*
              (>>))?
              (?:\s+(\#\w+))?
              \s*$///
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.type' }
            '3': { name: 'keyword.control' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'punctuation.definition.stereotype.begin' }
            '6': { name: 'constant.character' }
            '7': { name: 'constant.other.color' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: 'punctuation.definition.stereotype.end' }
            '10': { name: 'constant.other.color' }
        }
        {
          name: 'meta.class.declaring.block'
          begin: ///^\s*
              (class|abstract(?:\s+class)?|interface|annotation|enum)\s+
              ((?:[\w\u0080-\uFFFF]+|"[^"]+")(?:<[^>]+>)?)
              (?:\s+(as)\s+([\w\u0080-\uFFFF]+|"[^"]+"))?\s*
              (?:\s+(<<)\s*
                  (?:\((.),(\#?\w+)\))?\s*
                  ([^<>\(\)]+)?\s*
              (>>))?
              (?:\s+(\#\w+))?
              \s*({)\s*$///
          beginCaptures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.type' }
            '3': { name: 'keyword.control' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'punctuation.definition.stereotype.begin' }
            '6': { name: 'constant.character' }
            '7': { name: 'constant.other.color' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: 'punctuation.definition.stereotype.end' }
            '10': { name: 'constant.other.color' }
            '11': { name: 'punctuation.definition.block.begin' }
          end: /^\s*(})\s*$/
          endCaptures:
            '1': { name: 'punctuation.definition.block.end' }
          patterns: [
            {
              include: '#class_block'
            }
          ]
        }
        {
          name: 'meta.class.paramater'
          match: ///^\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s+
              (:)\s+
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $///
          captures:
            '1': { name: 'entity.name.type' }
            '2': { name: 'punctuation.definition.description' }
            '3': { name: 'keyword.other' }
            '4': { name: 'keyword.control' }
            '5': { name: 'keyword.control' }
            '6': { name: 'entity.name.type' }
            '7': { name: 'variable.paramater' }
            '8': { name: 'keyword.operator' }
            '9': { name: 'entity.name.type' }
        }
        {
          name: 'meta.class.method'
          begin: ///^\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s+
              (:)\s+
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              (\()\s*///
          end: ///\s*
              (\))\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $///
          beginCaptures:
            '1': { name: 'entity.name.type' }
            '2': { name: 'punctuation.definition.description' }
            '3': { name: 'keyword.other' }
            '4': { name: 'keyword.control' }
            '5': { name: 'keyword.control' }
            '6': { name: 'entity.name.type' }
            '7': { name: 'entity.name.function' }
            '8': { name: 'punctuation.definition.function.args.begin' }
          endCaptures:
            '1': { name: 'punctuation.definition.function.args.end' }
            '2': { name: 'keyword.operator' }
            '3': { name: 'entity.name.type' }
          patterns: [
            {
              include: '#class_function_arguments'
            }
          ]
        }
      ]
    # TODO: implement activity_diagram
    'activity_diagram':
      patterns: [
      ]
    # TODO: implement component_diagram
    'component_diagram':
      patterns: [
      ]
    # TODO: implement state_diagram
    'state_diagram':
      patterns: [
      ]
    # TODO: implement object_diagram
    'object_diagram':
      patterns: [
      ]
    # TODO: implement usecase
    'usecase_diagram':
      patterns: [
      ]
    'class_block':
      patterns: [
        {
          name: 'meta.class.separator'
          match: ///^\s*
              (--+|\.\.+|==+|__+)\s*
              (?:
                  ([^-\.=__]+)\s*
                  (--+|\.\.+|==+|__+)\s*
              )?
              $///
          captures:
            '1': { name: 'keyword.operator' }
            '2': { name: 'string.unquoted' }
            '3': { name: 'keyword.operator' }
        }
        {
          name: 'meta.class.paramater'
          match: ///^\s*
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $///
          captures: {
            '1': { name: 'keyword.other' }
            '2': { name: 'keyword.control' }
            '3': { name: 'keyword.control' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'variable.paramater' }
            '6': { name: 'keyword.operator' }
            '7': { name: 'entity.name.type' }
          }
        }
        {
          name: 'meta.class.method'
          begin: ///
              ^\s*
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              (\()\s*
              ///
          beginCaptures: {
            '1': { name: 'keyword.other' }
            '2': { name: 'keyword.control' }
            '3': { name: 'keyword.control' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'entity.name.function' }
            '6': { name: 'punctuation.definition.function.args.begin' }
          }
          end: ///
              \s*
              (\))\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $
              ///
          endCaptures: {
            '1': { name: 'punctuation.definition.function.args.end' }
            '2': { name: 'keyword.operator' }
            '3': { name: 'entity.name.type' }
          }
          patterns: [
            {
              include: '#class_function_arguments'
            }
          ]
        }
      ]
    'class_function_arguments':
      patterns: [
        {
          name: 'meta.function.argument'
          match: ///\s*
              (?:
                  ([^\(\):,\s][^\(\):,]*)\s+
              )?
              ([^\(\):,\s]+)\s*
              (?:
                  (:)\s*
                  ([^\(\):,\s][^\(\):,]*(?!<\s))
              )?\s*,?\s*
              ///
          captures: {
            '1': { name: 'entity.name.type' }
            '2': { name: 'variable.paramater' }
            '3': { name: 'keyword.operator' }
            '4': { name: 'entity.name.type' }
          }
        }
      ]


makeGrammar grammar, "CSON"
