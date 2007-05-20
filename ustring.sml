
structure Ustring = struct

type STRING = UTF8.wchar vector
type SOURCE = UTF8.wchar list


(*
 * Internal functions with intentionally ugly names
 * (only these guys know what a STRING really is)
 *)


fun internal_fromString s = Vector.fromList (UTF8.explode s)

fun internal_fromSource s = UTF8.explode s

fun internal_toEscapedAscii us =
    let
	fun esc (c, ls) = 
	    if UTF8.isAscii c then
		(UTF8.toAscii c) :: ls
	    else
		(List.rev (explode (UTF8.toString c))) @ ls
    in
	implode (List.rev (Vector.foldl esc [] us))
    end

fun fixNegative s = 
    if String.sub (s, 0) = #"~"
    then "-" ^ String.extract (s, 1, NONE)
    else s

fun internal_fromInt n = internal_fromString (fixNegative (Int.toString n))

fun internal_fromInt32 n = internal_fromString (fixNegative (Int32.toString n))

fun internal_fromCharCode n = #[Word.fromInt n]

fun internal_stringLength us = Vector.length us

fun internal_stringAppend a b = Vector.concat [a, b]

fun internal_charCodeAt us n = Word.toInt (Vector.sub (us, n))

fun internal_compare a b = Vector.collate Word.compare (a,b)

fun internal_substring us m n = VectorSlice.vector (VectorSlice.slice(us, m, SOME n))

fun internal_append uss = Vector.concat uss

fun internal_sourceFromUstring s = Vector.foldr (op ::) [] s


(*
 * Public interface
 *)

fun toAscii      (s:STRING   ) : string = internal_toEscapedAscii s
fun toFilename   (s:STRING   ) : string = internal_toEscapedAscii s  (* FIXME: what should I do here? *)

fun fromString   (s:string   ) : STRING = internal_fromString   s  (* Should be used sparingly. *)
fun fromSource   (s:string   ) : SOURCE = internal_fromSource   s
fun fromInt      (i:int      ) : STRING = internal_fromInt      i
fun fromInt32    (i:Int32.int) : STRING = internal_fromInt32    i
fun fromCharCode (i:int      ) : STRING = internal_fromCharCode i

fun stringLength (s:STRING   ) : int    = internal_stringLength s

fun stringAppend (a:STRING) (b:STRING) : STRING = internal_stringAppend a b
fun charCodeAt   (s:STRING) (i:int   ) : int    = internal_charCodeAt   s i
fun compare      (a:STRING) (b:STRING) : order  = internal_compare      a b

fun substring    (s:STRING) (m:int) (n:int) : STRING = internal_substring s m n

fun append       (l:STRING list) : STRING = internal_append l

fun sourceFromUstring (s:STRING) : SOURCE = internal_sourceFromUstring s


(*
 * pre-defined strings
 *)

val empty                    = fromString ""
val zero                     = fromString "0"
val asterisk                 = fromString "*"
val dollar                   = fromString "$"
val dot                      = fromString "."
val dash                     = fromString "-"
val undefined_               = fromString "undefined"
val temp_                    = fromString "temp"
val Object_                  = fromString "Object"
val object_                  = fromString "object"
val has_                     = fromString "has"
val call_                    = fromString "call"
val get_                     = fromString "get"
val set_                     = fromString "set"
val type_                    = fromString "type"
val number_                  = fromString "number"
val boolean_                 = fromString "boolean"
val function_                = fromString "function"
val string_                  = fromString "string"
val null_                    = fromString "null"
val constructor_             = fromString "constructor"
val length_                  = fromString "length"
val source_                  = fromString "source"
val prototype_               = fromString "prototype"
val toString_                = fromString "toString"
val valueOf_                 = fromString "valueOf"
val global_                  = fromString "global"
val invoke_                  = fromString "invoke"
val this_                    = fromString "this"
val arguments_               = fromString "arguments"
val Type_                    = fromString "Type"
val Interface_               = fromString "Interface"
val Class_                   = fromString "Class"
val Namespace_               = fromString "Namespace"
val Error_                   = fromString "Error"
val EvalError_               = fromString "EvalError"
val RangeError_              = fromString "RangeError"
val ReferenceError_          = fromString "ReferenceError"
val SyntaxError_             = fromString "SyntaxError"
val TypeError_               = fromString "TypeError"
val ToPrimitive_             = fromString "ToPrimitive"
val ToBoolean_               = fromString "ToBoolean"
val ToInteger_               = fromString "ToInteger"
val ToInt_                   = fromString "ToInt"
val ToUint_                  = fromString "ToUint"
val ToDouble_                = fromString "ToDouble"
val ToDecimal_               = fromString "ToDecimal"
val ToString_                = fromString "ToString"
val ToObject_                = fromString "ToObject"
val ToNumeric_               = fromString "ToNumeric"
val NaN_                     = fromString "NaN"
val Infinity_                = fromString "Infinity"
val eval_                    = fromString "eval"
val parseInt_                = fromString "parseInt"
val parseFloat_              = fromString "parseFloat"
val isNaN_                   = fromString "isNaN"
val isFinite_                = fromString "isFinite"
val decodeURI_               = fromString "decodeURI"
val decodeURIComponent_      = fromString "decodeURIComponent"
val encodeURI_               = fromString "encodeURI"
val encodeURIComponent_      = fromString "encodeURIComponent"
val JSON_                    = fromString "JSON"
val print_                   = fromString "print"
val load_                    = fromString "load"
val assert_                  = fromString "assert"
val typename_                = fromString "typename"
val Function_                = fromString "Function"
val Boolean_                 = fromString "Boolean"
val Number_                  = fromString "Number"
val double_                  = fromString "double"
val int_                     = fromString "int"
val uint_                    = fromString "uint"
val decimal_                 = fromString "decimal"
val Numeric_                 = fromString "Numeric"
val String_                  = fromString "String"
val Array_                   = fromString "Array"
val ByteArray_               = fromString "ByteArray"
val Date_                    = fromString "Date"
val RegExp_                  = fromString "RegExp"
val regexp_                  = fromString "regexp"
val exception_               = fromString "exception"
val emit_                    = fromString "emit"
val parse_                   = fromString "parse"
val magic_                   = fromString "magic"
val meta_                    = fromString "meta"
val cursor_                  = fromString "cursor"
val native_function_         = fromString "native function"
val interface_               = fromString "interface"
val class_                   = fromString "class"
val namespace_               = fromString "namespace"
val bool_                    = fromString "bool"
val bytearray_               = fromString "bytearray"
val proto_                   = fromString "proto"
val dumpFunc_                = fromString "dumpFunc"
val inspect_                 = fromString "inspect"
val tan_                     = fromString "tan"
val sqrt_                    = fromString "sqrt"
val sin_                     = fromString "sin"
val round_                   = fromString "round"
val random_                  = fromString "random"
val pow_                     = fromString "pow"
val log_                     = fromString "log"
val floor_                   = fromString "floor"
val exp_                     = fromString "exp"
val cos_                     = fromString "cos"
val ceil_                    = fromString "ceil"
val atan2_                   = fromString "atan2"
val atan_                    = fromString "atan"
val asin_                    = fromString "asin"
val acos_                    = fromString "acos"
val abs_                     = fromString "abs"
val now_                     = fromString "now"
val toPrecision_             = fromString "toPrecision"
val toExponential_           = fromString "toExponential"
val toFixedStep10_           = fromString "toFixedStep10"
val DaylightSavingsTA_       = fromString "DaylightSavingsTA"
val LocalTZA_                = fromString "LocalTZA"
val setByteArrayByte_        = fromString "setByteArrayByte"
val getByteArrayByte_        = fromString "getByteArrayByte"
val stringAppend_            = fromString "stringAppend"
val stringLength_            = fromString "stringLength"
val fromCharCode_            = fromString "fromCharCode"
val charCodeAt_              = fromString "charCodeAt"
val fnLength_                = fromString "fnLength"
val apply_                   = fromString "apply"
val bindString_              = fromString "bindString"
val bindBoolean_             = fromString "bindBoolean"
val bindDecimal_             = fromString "bindDecimal"
val bindDouble_              = fromString "bindDouble"
val bindUInt_                = fromString "bindUInt"
val bindInt_                 = fromString "bindInt"
val newDouble_               = fromString "newDouble"
val newUInt_                 = fromString "newUInt"
val newInt_                  = fromString "newInt"
val toPrimitive_             = fromString "toPrimitive"
val isPrimitive_             = fromString "isPrimitive"
val defaultValue_            = fromString "defaultValue"
val setPropertyIsDontEnum_   = fromString "setPropertyIsDontEnum"
val getPropertyIsDontDelete_ = fromString "getPropertyIsDontDelete"
val getPropertyIsDontEnum_   = fromString "getPropertyIsDontEnum"
val hasOwnProperty_          = fromString "hasOwnProperty"
val getPrototype_            = fromString "getPrototype"
val getClassName_            = fromString "getClassName"
val construct_               = fromString "construct"
val true_                    = fromString "true"
val false_                   = fromString "false"
val x_                       = fromString "x"

val emptySource              = []

end
