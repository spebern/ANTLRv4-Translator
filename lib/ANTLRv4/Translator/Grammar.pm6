use v6;

unit grammar ANTLRv4::Translator::Grammar;

token BLANK_LINE {
    \s* \n
}

token ID {
    <NameStartChar> <NameChar>*
}

token COMMENT {
    '/*' .*? '*/'
    | '//' \N*
}
token COMMENTS {
    [<COMMENT> \s*]+
}

token DocComment {
    '/*' .*? '*/'
}

token BlockComment {
    '/*' .*? '*/'
}

token LineComment {
    '//' \N*
}

token EscSeq {
    <[ b t n f r " ' \\ ]> 	# The standard escaped character set
    |	<UNICODE_ESC>		# A Java style Unicode escape sequence
    |	.			# Invalid escape
    |	$			# Invalid escape at end of file
}

# TODO check if important
# fragment EscAny
#    : Esc .
#    ;

token UNICODE_ESC {
    'u' <HEX_DIGIT> ** {4}
}

token DIGITS {
    <DIGIT>+
}

token DIGIT {
    <[ 0..9 ]>
}

token DecimalNumeral {
    '0' | <[ 1 .. 9 ]> <DecDigit>*
}

token HEX_DIGIT {
   <[ 0 .. 9 a .. f A .. F ]>
}

token DecDigit {
   <[ 0 .. 9 ]>
}

token BoolLiteral {
   'true' | 'false'
}

rule CharLiteral {
    <SQuote> ( <EscSeq> | <-[ ' \r \n \\ ]> ) <SQuote>
}

rule SQuoteLiteral {
    <SQuote> ( :!sigspace [ '\\' <EscSeq> | <-[ ' \r \n \\ ]> ]* ) <SQuote>
}

rule DQuoteLiteral {
    <DQuote> ( <EscSeq> | <-[ " \r \n \\ ]> )* <DQuote>
}

rule USQuoteLiteral {
   <SQuote> ( <EscSeq> | <-[ ' \r \n \\ ]> )*
}

token NameChar {
    <NameStartChar>
    |	<DIGIT>
    |	'_'
    |	\x[00B7]
    |	<[ \x[0300]..\x[036F] ]>
    |	<[ \x[203F]..\x[2040] ]>
}

token NameStartChar {
    <[ A..Z ]>
    |	<[ a..z ]>
    |	<[ \x[00C0]..\x[00D6] ]>
    |	<[ \x[00D8]..\x[00F6] ]>
    |	<[ \x[00F8]..\x[02FF] ]>
    |	<[ \x[0370]..\x[037D] ]>
    |	<[ \x[037F]..\x[1FFF] ]>
    |	<[ \x[200C]..\x[200D] ]>
    |	<[ \x[2070]..\x[218F] ]>
    |	<[ \x[2C00]..\x[2FEF] ]>
    |	<[ \x[3001]..\x[D7FF] ]>
    |	<[ \x[F900]..\x[FDCF] ]>
    |	<[ \x[FDF0]..\x[FFFD] ]>
}

token Int {
   'int'
}

token Esc {
   '\\'
}

token Colon {
    ':'
}

token DColon {
    '::'
}

token SQuote {
   '\''
}


token DQuote {
    '"'
}

token LParen {
    '('
}

token RParen {
    ')'
}

token LBrace {
    '{'
}

token RBrace {
   '}'
}


token LBrack {
    '['
}

token RBrack {
    ']'
}

token RArrow {
    '->'
}

token Lt {
    '<'
}

token Gt {
    '>'
}

token Equal {
    '='
}

token Question {
    '?'
}

token Star {
   '*'
}

token Plus {
   '+'
}

token PlusAssign {
    '+='
}

token Underscore {
    '_'
}

token Pipe {
    '|'
}

token Dollar {
    '$'
}

token Comma {
    ','
}

token Semi {
    ';'
}

token Dot {
    '.'
}

token Range {
    '..'
}

token At {
    '@'
}

token Pound {
    '#'
}

token Tilde {
    '~'
}

rule DOC_COMMENT {
    <DocComment>
}

rule BLOCK_COMMENT {
    <BlockComment>
}

rule INT {
    <DecimalNumeral>
}

rule STRING_LITERAL {
    <SQuoteLiteral>
}

rule UNTERMINATED_STRING_LITERAL {
    <USQuoteLiteral>
}

rule BEGIN_ARGUMENT {
    <LBrack> # { handleBeginArgument(); };
}

rule BEGIN_ACTION {
   <LBrace>
}

rule OPTIONS {
    'options'
}

rule TOKENS {
   'tokens'
}


rule CHANNELS {
    'channels'
}


rule IMPORT {
    'import'
}

rule FRAGMENT {
    'fragment'
}

rule LEXER {
    'lexer'
}

rule PARSER {
    'parser'
}

rule GRAMMAR {
   'grammar'
}

rule PROTECTED {
    'protected'
}

rule PUBLIC {
    'public'
}

rule PRIVATE {
    'private'
}

rule RETURNS {
    'returns'
}

rule LOCALS {
    'locals'
}

rule THROWS {
    'throws'
}

rule CATCH {
    'catch'
}

rule FINALLY {
    'finally'
}

rule MODE {
    'mode'
}

rule COLON {
   <Colon>
}

rule COLONCOLON {
   <DColon>
}

rule COMMA {
   <Comma>
}

rule SEMI {
   <Semi>
}

rule LPAREN {
   <LParen>
}

rule RPAREN {
   <RParen>
}

rule LBRACE {
   <LBrace>
}

rule RBRACE {
   <RBrace>
}

rule RARROW {
   <RArrow>
}

rule LT {
   <Lt>
}

rule GT {
   <Gt>
}

rule ASSIGN {
   <Equal>
}

rule QUESTION {
   <Question>
}

rule STAR {
   <Star>
}

rule PLUS_ASSIGN {
   <PlusAssign>
}

rule PLUS {
   <Plus>
}

rule OR {
   <Pipe>
}

rule DOLLAR {
   <Dollar>
}

rule RANGE {
   <Range>
}

rule DOT {
   <Dot>
}

rule AT {
   <At>
}

rule POUND {
   <Pound>
}

rule NOT {
   <Tilde>
}

rule WS {
   <Ws>+
}

rule ERRCHAR {
   .
}

rule NESTED_ARGUMENT {
   <LBrack>
}

rule ARGUMENT_ESCAPE {
   <EscAny>
}

rule ARGUMENT_STRING_LITERAL {
   <DQuoteLiteral>
}

rule ARGUMENT_CHAR_LITERAL {
   <SQuoteLiteral>
}

rule END_ARGUMENT {
   <RBrack>
}

rule UNTERMINATED_ARGUMENT {
   <EOF>
}

rule ARGUMENT_CONTENT {
   .
}

rule NESTED_ACTION {
   <LBrace>
}

rule ACTION_ESCAPE {
   <EscAny>
}

rule ACTION_STRING_LITERAL {
   <DQuoteLiteral>
}


rule ACTION_CHAR_LITERAL {
   <SQuoteLiteral>
}

rule ACTION_DOC_COMMENT {
   <DocComment>
}

rule ACTION_BLOCK_COMMENT {
   <BlockComment>
}

rule ACTION_LINE_COMMENT {
   <LineComment>
}

rule END_ACTION {
   <RBrace>
}

rule UNTERMINATED_ACTION {
   <EOF>
}

rule ACTION_CONTENT {
    .
}

rule OPT_DOC_COMMENT {
   <DocComment>
}

rule OPT_BLOCK_COMMENT {
   <BlockComment>
}

rule OPT_LINE_COMMENT {
   <LineComment>
}

rule OPT_LBRACE {
   <LBrace>
}

rule OPT_RBRACE {
   <RBrace>
}

rule OPT_ID {
   <Id>
}

rule OPT_DOT {
   <Dot>
}

rule OPT_ASSIGN {
   <Equal>
}

rule OPT_STRING_LITERAL {
   <SQuoteLiteral>
}

rule OPT_INT {
   <Int>
}

rule OPT_STAR {
   <Star>
}

rule OPT_SEMI {
   <Semi>
}

rule OPT_WS {
   <Ws>+
}

rule TOK_DOC_COMMENT {
   <DocComment>
}

rule TOK_BLOCK_COMMENT {
   <BlockComment>
}

rule TOK_LINE_COMMENT {
   <LineComment>
}

rule TOK_LBRACE {
   <LBrace>
}

rule TOK_RBRACE {
   <RBrace>
}

rule TOK_ID {
   <Id>
}

rule TOK_DOT {
   <Dot>
}

rule TOK_COMMA {
   <Comma>
}

rule TOK_WS {
   <Ws>+
}

rule CHN_DOC_COMMENT {
   <DocComment>
}

rule CHN_BLOCK_COMMENT {
   <BlockComment>
}

rule CHN_LINE_COMMENT {
   <LineComment>
}

rule CHN_LBRACE {
   <LBrace>
}

rule CHN_RBRACE {
   <RBrace>
}

rule CHN_ID {
   <Id>
}

rule CHN_DOT {
   <Dot>
}

rule CHN_COMMA {
   <Comma>
}

rule CHN_WS {
   <Ws>+
}

token LEXER_CHAR_SET_ELEMENT {
    '\\' <-[ u ]>
    | '\\' <UNICODE_ESC>
    | <-[ \\ \x[5d] ]>
}

token LEXER_CHAR_SET_ELEMENT_NO_HYPHEN {
    '\\' <-[ u ]>
    | '\\' <UNICODE_ESC>
    | <-[ - \\ \x[5d] ]>
}

token LEXER_CHAR_SET_RANGE {
    [ <LEXER_CHAR_SET_ELEMENT_NO_HYPHEN> '-' ]? <LEXER_CHAR_SET_ELEMENT>
}

token LEXER_CHAR_SET {
    '[' (<LEXER_CHAR_SET_RANGE> | <LEXER_CHAR_SET_ELEMENT>)* ']'
}


rule UNTERMINATED_CHAR_SET {
   <EOF>
}

# rule grammarSpec {
rule TOP {
    <BLANK_LINE>* <COMMENTS>?
    <grammarType> <name=ID> <SEMI> <prequelConstruct>* <rules> <modeSpec>*
}

rule grammarType {
    [ <LEXER> <GRAMMAR> | <PARSER> <GRAMMAR> | <GRAMMAR> ]
}

rule prequelConstruct {
    [
        <optionsSpec>
        | <delegateGrammars>
        | <tokensSpec>
        | <channelsSpec>
        | <action>
    ]
}

rule optionsSpec {
    <OPTIONS> <LBRACE> ( <option> <SEMI> )* <RBRACE>
}

rule option {
    <ID> <ASSIGN> <optionValue>
}

rule optionValue {
    [
        <ID> ( <DOT> <ID> )*
        | <STRING_LITERAL>
        | <actionBlock>
        | <INT>
   ]
}

rule delegateGrammars {
    <IMPORT> <delegateGrammar> ( <COMMA> <delegateGrammar> )* <SEMI>
}

rule delegateGrammar {
    [
        <ID> <ASSIGN> <ID>
        | <ID>
    ]
}

rule tokensSpec {
   <TOKENS> <LBRACE> <idList>? <RBRACE>
}

rule channelsSpec {
   <CHANNELS> <LBRACE> <idList>? <RBRACE>
}

rule idList {
    <ID> ( <COMMA> <ID> )* <COMMA>?
}

rule action {
    <AT> ( <actionScopeName> <COLONCOLON>)? <ID> <actionBlock>
}

rule actionScopeName {
    [
        <ID>
        | <LEXER>
        | <PARSER>
    ]
}

rule actionBlock {
    <BEGIN_ACTION> <ACTION_CONTENT>* <END_ACTION>
}

rule argActionBlock {
    <BEGIN_ARGUMENT> <ARGUMENT_CONTENT>* <END_ARGUMENT>
}

rule modeSpec {
    <MODE> <ID> <SEMI> <lexerRuleSpec>*
}

rule rules {
    <ruleSpec>*
}

rule ruleSpec {
    [
        <parserRuleSpec>
        | <lexerRuleSpec>
    ]
}

# rule parserRuleSpec {
#     <DOC_COMMENT>* <ruleModifiers>? <RULE_REF> <argActionBlock>? <ruleReturns>?
#     <throwsSpec>? <localsSpec>? <rulePrequel>* <COLON> <ruleBlock> <SEMI> <exceptionGroup>
# }
rule parserRuleSpec {
    <DOC_COMMENT>* <ruleModifiers>? <argActionBlock>? <ruleReturns>?
    <throwsSpec>? <localsSpec>? <rulePrequel>* <COLON> <ruleBlock> <SEMI> <exceptionGroup>
}

rule exceptionGroup {
    <exceptionHandler>* <finallyClause>?
}

rule exceptionHandler {
    <CATCH> <argActionBlock> <actionBlock>
}

rule finallyClause {
    <FINALLY> <actionBlock>
}

rule rulePrequel {
    [
        <optionsSpec>
        | <ruleAction>
    ]
}

rule ruleReturns {
    <RETURNS> <argActionBlock>
}

rule throwsSpec {
    <THROWS> <ID> ( <COMMA> <ID> )*
}

rule localsSpec {
    <LOCALS> <argActionBlock>
}

rule ruleAction {
    <AT> <ID> <actionBlock>
}

rule ruleModifiers {
    <ruleModifier>+
}

rule ruleModifier {
    [
        <PUBLIC>
        | <PRIVATE>
        | <PROTECTED>
        | <FRAGMENT>
    ]
}

rule ruleBlock {
    <ruleAltList>
}

rule ruleAltList {
    <labeledAlt> ( <OR> <labeledAlt> )*
}

rule labeledAlt {
    <alternative> ( <POUND> <ID> )?
}

rule lexerRuleSpec {
    <DOC_COMMENT>* <FRAGMENT>? <name=ID> <COLON> <lexerRuleBlock> <SEMI> <LineComment>?
}

rule lexerRuleBlock {
    <lexerAltList>
}

rule lexerAltList {
    <lexerAlt>+ %% <OR>
}

# TODO needs to be checked
# lexerAlt
#    : lexerElements lexerCommands?
#    |
#    // explicitly allow empty alts
#    ;
rule lexerAlt {
    [
        <lexerElements> <lexerCommands>?
        | Nil
    ]
}

rule lexerElements {
    <lexerElement>+
}


rule lexerElement {
    [
        <labeledLexerElement> <ebnfSuffix>?
        | <lexerAtom> <ebnfSuffix>?
        | <lexerBlock> <ebnfSuffix>?
        | <actionBlock> <QUESTION>?
    ]
}

rule labeledLexerElement {
    <ID> [ <ASSIGN> | <PLUS_ASSIGN> ] [ <lexerAtom> | <block> ]
}

rule lexerBlock {
    <LPAREN> <lexerAltList> <RPAREN>
}

rule lexerCommands {
   <RARROW> <lexerCommand> ( <COMMA> <lexerCommand> )*
}

rule lexerCommand {
    [
        <lexerCommandName> <LPAREN> <lexerCommandExpr> <RPAREN>
        | <lexerCommandName>
    ]
}

rule lexerCommandName {
    [
        <ID>
        | <MODE>
    ]
}

rule lexerCommandExpr {
    [
        <ID>
        | <INT>
    ]
}

rule altList {
   <alternative> ( <OR> <alternative> )*
}


# alternative
#    : elementOptions? element +
#    |
#    // explicitly allow empty alts
#    ;
# TODO needs to be checked
rule alternative {
    [
        <elementOptions>? <element>+
        | Nil
    ]
}

rule element {
    [
        <labeledElement> <ebnfSuffix>?
        | <atom> <ebnfSuffix>?
        | <ebnf>
        | <actionBlock> <QUESTION>?
    ]
}

rule labeledElement {
    <ID> [ <ASSIGN> | <PLUS_ASSIGN> ] [ <atom> | <block> ]
}

rule ebnf {
    <block> <blockSuffix>?
}

rule blockSuffix {
    <ebnfSuffix>
}

rule ebnfSuffix {
    [
        <QUESTION> <QUESTION>?
        | <STAR> <QUESTION>?
        | <PLUS> <QUESTION>?
    ]
}

rule lexerAtom {
    [
        <characterRange>
        | <terminal>
        | <notSet>
        | <LEXER_CHAR_SET>
        | <DOT> <elementOptions>?
    ]
}

rule atom {
    [
        <characterRange>
        | <terminal>
        | <ruleref>
        | <notSet>
        | <DOT> <elementOptions>?
    ]
}

rule notSet {
    [
        <NOT> <setElement>
        | <NOT> <blockSet>
    ]
}

rule blockSet {
    <LPAREN> <setElement> ( <OR> <setElement> )* <RPAREN>
}

rule setElement {
    [
        <ID> <elementOptions>?
        | <STRING_LITERAL> <elementOptions>?
        | <characterRange>
        | <LEXER_CHAR_SET>
    ]
}

rule block {
    <LPAREN> ( <optionsSpec>? <ruleAction>* <COLON> )? <altList> <RPAREN>
}

rule ruleref {
    <RULE_REF> <argActionBlock>? <elementOptions>?
}

rule characterRange {
    <STRING_LITERAL> <RANGE> <STRING_LITERAL>
}

rule terminal {
    [
        <ID> <elementOptions>?
        | <STRING_LITERAL> <elementOptions>?
    ]
}

rule elementOptions {
    <LT> <elementOption> ( <COMMA> <elementOption> )* <GT>
}

rule elementOption {
    [
        <ID>
        | <ID> <ASSIGN> ( <ID> | <STRING_LITERAL> )
    ]
}
