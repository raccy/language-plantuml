{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: "PlantUML"
  scopeName: "source.plantuml"
  fileTypes: [ "puml", "plantuml", "txt" ]

  macros:
    color: /\#\w+/
    entityName: /[\w\u0080-\uFFFF]+/
    entityQuoted: /"[^"]+"/
    entity: /(?:{entityName}|{entityQuoted})/
    arrowColor: ///
                [ox]?
                (?:<<?|\\\\?|//?)?
                -(?:\[({color})\])?-?
                (?:>>?|\\\\?|//?)?
                (?:[ox](?=[\s\]"]))?
                ///
    stringQuoted: /{entityQuoted}/
    participant: /(?:actor|boundary|control|entity|database|participant)/

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
                  ({entity})
                  (\s*,\s*({entity}))*
                )?
                (?:\s+({color}))?
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
                \s+((?:left|right)(?:\s+of)|over)
                (?:\s+
                  ({entity})
                  (\s*,\s*({entity}))*
                )?
                (?:\s+({color}))?
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
                create(?:\s+{participant})?
                |
                {participant}
              )\s+
              (?:({entity})\s+(as))?
              \s+({entity})
              (?:\s+(<<)\s*
                (?:\((.),({color})\))?
                (.*)
              \s*(>>))?
              (?:\s+({color}))?
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
          match: /^\s*(activate)\s+({entity})(?:\s+({color}))?\s*$/
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.type' }
            '3': { name: 'constant.other.color' }
        }
        {
          name: 'meta.sequence.deactivate'
          match: /^\s*(deactivate|destroy)\s+(.*)\s*$/
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'entity.name.type' }
        }
        {
          name: 'meta.sequence.arrow.incoming'
          match: ///
                ^\s*
                (\[)
                ({arrowColor})\s*
                ({entity})
                (?:\s+(as)\s+({entity}))?\s*
                (:)\s*
                (.*)$
                ///
          patterns: [
            { include: 'sequence_arrow' }
          ]
          captures:
            '1': { name: 'meta.class.incoming' }
            '2': { name: 'meta.class.arrow' }
            '3': { name: 'constant.other.color' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'keyword.control' }
            '6': { name: 'entity.name.type' }
            '7': { name: 'constant.other.color' }
            '8': { name: 'string.unquoted' }
        }
        {
          name: 'meta.sequence.arrow.outgoing'
          match: ///
                ^\s*
                ({entity})\s*
                ({arrowColor})
                (\])\s*
                (:)\s*
                (.*)$
                ///
          captures:
            '1': { name: 'entity.name.type' }
            '2': { name: 'meta.class.arrow' }
            '3': { name: 'constant.other.color' }
            '4': { name: 'meta.class.outgoing' }
            '5': { name: 'constant.other.color' }
            '6': { name: 'string.unquoted' }
        }
        {
          name: 'meta.sequence.arrow'
          match: ///
                ^\s*
                ({entity})\s*
                ({arrowColor})\s*
                ({entity})
                (?:\s+(as)\s+({entity}))?\s*
                (:)\s*
                (.*)$
                ///
          captures:
            '1': { name: 'entity.name.type' }
            '2': { name: 'meta.class.arrow' }
            '3': { name: 'constant.other.color' }
            '4': { name: 'entity.name.type' }
            '5': { name: 'keyword.control' }
            '6': { name: 'entity.name.type' }
            '7': { name: 'constant.other.color' }
            '8': { name: 'string.unquoted' }
        }
        {
          name: 'meta.sequence.verticalspace'
          match: ///^\s*
                (?:
                  (\|{3})
                  |
                  (\|\|(\d+)\|\|)
                )\s*$
                ///
          captures:
            '1': { name: 'keyword.control' }
            '2': { name: 'keyword.control' }
            '3': { name: 'variable.language' }
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
              (?:\s+({color}))?
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
              (?:\s+({color}))?
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
