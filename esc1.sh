echo esc1 $1
cp $1 esc-tmp.es
make run-dumped FILE="tests/self/debug.es tests/self/util.es tests/self/util-es4ri.es tests/self/ast.es tests/self/decoder.es tests/self/encoder.es tests/self/lex-char.es tests/self/lex-token.es tests/self/lex-scan.es tests/self/parse-util.es tests/self/parse-ident.es tests/self/parse-expr.es tests/self/parse-ptrn.es tests/self/parse-type.es tests/self/parse-stmt.es tests/self/parse-defn.es tests/self/parse-prgm.es tests/self/esc1.es"
cp esc-tmp.ast $1.1.ast
cp esc-tmp.ast $1.ast
rm esc-tmp.es
rm esc-tmp.ast


