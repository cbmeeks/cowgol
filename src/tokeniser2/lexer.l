%{
%}
%x string
%x skipping

LF (\r\n)|\r|\n
SP [ \t]+

%%
"!="                      { emit_token(TOKEN_NEOP); }
"%"                       { emit_token(TOKEN_PERCENT); }
"&"                       { emit_token(TOKEN_AMPERSAND); }
"("                       { emit_token(TOKEN_OPENPAREN); }
")"                       { emit_token(TOKEN_CLOSEPAREN); }
"*"                       { emit_token(TOKEN_STAR); }
"+"                       { emit_token(TOKEN_PLUS); }
","                       { emit_token(TOKEN_COMMA); }
"-"                       { emit_token(TOKEN_MINUS); }
"."                       { emit_token(TOKEN_DOT); }
"/"                       { emit_token(TOKEN_SLASH); }
":"                       { emit_token(TOKEN_COLON); }
":="                      { emit_token(TOKEN_ASSIGN); }
";"                       { emit_token(TOKEN_SEMICOLON); }
"<"                       { emit_token(TOKEN_LTOP); }
"<<"                      { emit_token(TOKEN_LEFTSHIFT); }
"<="                      { emit_token(TOKEN_LEOP); }
"=="                      { emit_token(TOKEN_EQOP); }
">"                       { emit_token(TOKEN_GTOP); }
">="                      { emit_token(TOKEN_GEOP); }
">>"                      { emit_token(TOKEN_RIGHTSHIFT); }
"["                       { emit_token(TOKEN_OPENSQUARE); }
"]"                       { emit_token(TOKEN_CLOSESQUARE); }
"^"                       { emit_token(TOKEN_CARET); }
"{"                       { emit_token(TOKEN_OPENBRACE); }
"|"                       { emit_token(TOKEN_PIPE); }
"}"                       { emit_token(TOKEN_CLOSEBRACE); }
"~"                       { emit_token(TOKEN_TILDE); }
@bytes                    { emit_token(TOKEN_BYTES); }
@index                    { emit_token(TOKEN_INDEX); }
@segment                  { emit_token(TOKEN_SEGMENT); }
@size                     { emit_token(TOKEN_SIZE); }
and                       { emit_token(TOKEN_AND); }
as                        { emit_token(TOKEN_AS); }
break                     { emit_token(TOKEN_BREAK); }
const                     { emit_token(TOKEN_CONST); }
continue                  { emit_token(TOKEN_CONTINUE); }
else                      { emit_token(TOKEN_ELSE); }
elseif                    { emit_token(TOKEN_ELSEIF); }
end                       { emit_token(TOKEN_END); }
goto                      { emit_token(TOKEN_GOTO); }
if                        { emit_token(TOKEN_IF); }
loop                      { emit_token(TOKEN_LOOP); }
namespace                 { emit_token(TOKEN_NAMESPACE); }
not                       { emit_token(TOKEN_NOT); }
or                        { emit_token(TOKEN_OR); }
record                    { emit_token(TOKEN_RECORD); }
return                    { emit_token(TOKEN_RETURN); }
sub                       { emit_token(TOKEN_SUB); }
then                      { emit_token(TOKEN_THEN); }
var                       { emit_token(TOKEN_VAR); }
while                     { emit_token(TOKEN_WHILE); }

[a-zA-Z_][a-zA-Z0-9_]*    { emit_identifier(); }

\"                        { start_state := STATE_STRING; string_start(); }
<string>\\n               { string_add_char('\n'); }
<string>\\r               { string_add_char('\r'); }
<string>\\t               { string_add_char(9); }
<string>\\x[0-9A-Fa-f]{2} { string_add_char(parse_hex_byte(current_token_start+2)); }
<string>\\[\\"]           { string_add_char(tokenbuffer[current_token_start+1]); }
<string>\"                { start_state := STATE_INITIAL; string_end(); }
<string>\\.               { print("bogus escape"); fail(); }
<string>[\n\r]            { print("unterminated string"); fail(); }
<string>[^\n\r\\"]+       { string_add_chars(); }

\'\\n\'                   { emit_small_const('\n'); }
\'\\r\'                   { emit_small_const('\r'); }
\'\\t\'                   { emit_small_const(9); }
\'\\['\\]\'               { emit_small_const(tokenbuffer[current_token_start+2]); }
\'\\x[0-9A-Fa-f]{2}\'     { emit_small_const(parse_hex_byte(current_token_start+3)); }
\'\\.\'                   { print("bogus escape"); fail(); }
\'[^']\'                  { emit_small_const(tokenbuffer[current_token_start+1]); }


0b[_01]+                  { emit_number(2, 2); }
0o[_0-7]+                 { emit_number(8, 2); }
0x[_0-9A-Fa-f]+           { emit_number(16, 2); }
[0-9][_0-9]*              { emit_number(10, 0); }

#[^\r\n]*                 |
{SP}+                     {}

\$set{SP}DEBUG            { debugging := 1; }
\$if{SP}DEBUG             { if debugging == 0 then start_state := STATE_SKIPPING; end if; }
<skipping>\$endif         { start_state := STATE_INITIAL; }
<skipping>[^$\r\n]+       { }

\$endif                   { }
<INITIAL,skipping>\$      { print("invalid compilation directive"); fail(); }
<INITIAL,skipping>{LF}    { current_line := current_line + 1; }

.                         { print("unparsable byte 0x"); print_hex_i8(tokenbuffer[current_token_start]); fail(); }
