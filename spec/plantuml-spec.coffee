describe "PlantUML grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-plantuml")

    runs ->
      grammar = atom.grammars.grammarForScopeName("sorurce.plantuml")

  it "parse the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.ruby"
