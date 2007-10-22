structure PrettyCvt = struct
   open Ast
   fun cvtSOURCE_POS {line=n0, col=n1} = PrettyRep.Rec [("line", PrettyRep.Int n0), 
          ("col", PrettyRep.Int n1)]
   and cvtLOC {file=s7, span=(x8, x9), post_newline=b11} = PrettyRep.Rec [("file", 
          PrettyRep.String s7), ("span", PrettyRep.Tuple [cvtSOURCE_POS x8, 
          cvtSOURCE_POS x9]), ("post_newline", PrettyRep.Bool b11)]
   and cvtIDENT s19 = PrettyRep.UniStr s19
   and cvtUNIT_NAME ls21 = PrettyRep.List (List.map (fn x20 => cvtIDENT x20
                                                    ) ls21)
   and cvtRIB_ID n25 = PrettyRep.Int n25
   and cvtNAMESPACE (Intrinsic) = PrettyRep.Ctor ("Intrinsic", NONE)
     | cvtNAMESPACE (OperatorNamespace) = PrettyRep.Ctor ("OperatorNamespace", 
          NONE)
     | cvtNAMESPACE (Private x28) = PrettyRep.Ctor ("Private", SOME (cvtIDENT x28))
     | cvtNAMESPACE (Protected x31) = PrettyRep.Ctor ("Protected", SOME (cvtIDENT x31))
     | cvtNAMESPACE (Public x34) = PrettyRep.Ctor ("Public", SOME (cvtIDENT x34))
     | cvtNAMESPACE (Internal x37) = PrettyRep.Ctor ("Internal", SOME (cvtIDENT x37))
     | cvtNAMESPACE (UserNamespace s40) = PrettyRep.Ctor ("UserNamespace", 
          SOME (PrettyRep.UniStr s40))
     | cvtNAMESPACE (AnonUserNamespace n43) = PrettyRep.Ctor ("AnonUserNamespace", 
          SOME (PrettyRep.Int n43))
     | cvtNAMESPACE (LimitedNamespace(x46, x47)) = PrettyRep.Ctor ("LimitedNamespace", 
          SOME (PrettyRep.Tuple [cvtIDENT x46, cvtNAMESPACE x47]))
   and cvtNAME {ns=x51, id=x52} = PrettyRep.Rec [("ns", cvtNAMESPACE x51), 
          ("id", cvtIDENT x52)]
   and cvtMULTINAME {nss=ls63, id=x67} = PrettyRep.Rec [("nss", PrettyRep.List (List.map (fn ls59 => 
                                                                                                PrettyRep.List (List.map (fn x58 => 
                                                                                                                                cvtNAMESPACE x58
                                                                                                                         ) ls59)
                                                                                         ) ls63)), 
          ("id", cvtIDENT x67)]
   and cvtNUMBER_TYPE (Decimal) = PrettyRep.Ctor ("Decimal", NONE)
     | cvtNUMBER_TYPE (Double) = PrettyRep.Ctor ("Double", NONE)
     | cvtNUMBER_TYPE (Int) = PrettyRep.Ctor ("Int", NONE)
     | cvtNUMBER_TYPE (UInt) = PrettyRep.Ctor ("UInt", NONE)
     | cvtNUMBER_TYPE (Byte) = PrettyRep.Ctor ("Byte", NONE)
     | cvtNUMBER_TYPE (Number) = PrettyRep.Ctor ("Number", NONE)
   and cvtNUMERIC_MODE {numberType=x79, roundingMode=r80, precision=n81} = 
          PrettyRep.Rec [("numberType", cvtNUMBER_TYPE x79), ("roundingMode", 
          PrettyRep.DecRm r80), ("precision", PrettyRep.Int n81)]
   and cvtBINTYPEOP (Cast) = PrettyRep.Ctor ("Cast", NONE)
     | cvtBINTYPEOP (Is) = PrettyRep.Ctor ("Is", NONE)
     | cvtBINTYPEOP (To) = PrettyRep.Ctor ("To", NONE)
   and cvtBINOP (Plus opt93) = PrettyRep.Ctor ("Plus", SOME 
       (case opt93 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x92 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x92))
       ))
     | cvtBINOP (Minus opt100) = PrettyRep.Ctor ("Minus", SOME 
       (case opt100 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x99 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x99))
       ))
     | cvtBINOP (Times opt107) = PrettyRep.Ctor ("Times", SOME 
       (case opt107 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x106 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x106))
       ))
     | cvtBINOP (Divide opt114) = PrettyRep.Ctor ("Divide", SOME 
       (case opt114 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x113 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x113))
       ))
     | cvtBINOP (Remainder opt121) = PrettyRep.Ctor ("Remainder", SOME 
       (case opt121 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x120 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x120))
       ))
     | cvtBINOP (LeftShift) = PrettyRep.Ctor ("LeftShift", NONE)
     | cvtBINOP (RightShift) = PrettyRep.Ctor ("RightShift", NONE)
     | cvtBINOP (RightShiftUnsigned) = PrettyRep.Ctor ("RightShiftUnsigned", 
          NONE)
     | cvtBINOP (BitwiseAnd) = PrettyRep.Ctor ("BitwiseAnd", NONE)
     | cvtBINOP (BitwiseOr) = PrettyRep.Ctor ("BitwiseOr", NONE)
     | cvtBINOP (BitwiseXor) = PrettyRep.Ctor ("BitwiseXor", NONE)
     | cvtBINOP (LogicalAnd) = PrettyRep.Ctor ("LogicalAnd", NONE)
     | cvtBINOP (LogicalOr) = PrettyRep.Ctor ("LogicalOr", NONE)
     | cvtBINOP (InstanceOf) = PrettyRep.Ctor ("InstanceOf", NONE)
     | cvtBINOP (In) = PrettyRep.Ctor ("In", NONE)
     | cvtBINOP (Equals opt138) = PrettyRep.Ctor ("Equals", SOME 
       (case opt138 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x137 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x137))
       ))
     | cvtBINOP (NotEquals opt145) = PrettyRep.Ctor ("NotEquals", SOME 
       (case opt145 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x144 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x144))
       ))
     | cvtBINOP (StrictEquals opt152) = PrettyRep.Ctor ("StrictEquals", SOME 
       (case opt152 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x151 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x151))
       ))
     | cvtBINOP (StrictNotEquals opt159) = PrettyRep.Ctor ("StrictNotEquals", 
          SOME 
       (case opt159 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x158 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x158))
       ))
     | cvtBINOP (Less opt166) = PrettyRep.Ctor ("Less", SOME 
       (case opt166 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x165 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x165))
       ))
     | cvtBINOP (LessOrEqual opt173) = PrettyRep.Ctor ("LessOrEqual", SOME 
       (case opt173 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x172 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x172))
       ))
     | cvtBINOP (Greater opt180) = PrettyRep.Ctor ("Greater", SOME 
       (case opt180 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x179 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x179))
       ))
     | cvtBINOP (GreaterOrEqual opt187) = PrettyRep.Ctor ("GreaterOrEqual", 
          SOME 
       (case opt187 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x186 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x186))
       ))
     | cvtBINOP (Comma) = PrettyRep.Ctor ("Comma", NONE)
   and cvtASSIGNOP (Assign) = PrettyRep.Ctor ("Assign", NONE)
     | cvtASSIGNOP (AssignPlus opt196) = PrettyRep.Ctor ("AssignPlus", SOME 
       (case opt196 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x195 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x195))
       ))
     | cvtASSIGNOP (AssignMinus opt203) = PrettyRep.Ctor ("AssignMinus", SOME 
       (case opt203 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x202 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x202))
       ))
     | cvtASSIGNOP (AssignTimes opt210) = PrettyRep.Ctor ("AssignTimes", SOME 
       (case opt210 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x209 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x209))
       ))
     | cvtASSIGNOP (AssignDivide opt217) = PrettyRep.Ctor ("AssignDivide", 
          SOME 
       (case opt217 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x216 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x216))
       ))
     | cvtASSIGNOP (AssignRemainder opt224) = PrettyRep.Ctor ("AssignRemainder", 
          SOME 
       (case opt224 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x223 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x223))
       ))
     | cvtASSIGNOP (AssignLeftShift) = PrettyRep.Ctor ("AssignLeftShift", NONE)
     | cvtASSIGNOP (AssignRightShift) = PrettyRep.Ctor ("AssignRightShift", 
          NONE)
     | cvtASSIGNOP (AssignRightShiftUnsigned) = PrettyRep.Ctor ("AssignRightShiftUnsigned", 
          NONE)
     | cvtASSIGNOP (AssignBitwiseAnd) = PrettyRep.Ctor ("AssignBitwiseAnd", 
          NONE)
     | cvtASSIGNOP (AssignBitwiseOr) = PrettyRep.Ctor ("AssignBitwiseOr", NONE)
     | cvtASSIGNOP (AssignBitwiseXor) = PrettyRep.Ctor ("AssignBitwiseXor", 
          NONE)
     | cvtASSIGNOP (AssignLogicalAnd) = PrettyRep.Ctor ("AssignLogicalAnd", 
          NONE)
     | cvtASSIGNOP (AssignLogicalOr) = PrettyRep.Ctor ("AssignLogicalOr", NONE)
   and cvtUNOP (Delete) = PrettyRep.Ctor ("Delete", NONE)
     | cvtUNOP (Void) = PrettyRep.Ctor ("Void", NONE)
     | cvtUNOP (Typeof) = PrettyRep.Ctor ("Typeof", NONE)
     | cvtUNOP (PreIncrement opt242) = PrettyRep.Ctor ("PreIncrement", SOME 
       (case opt242 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x241 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x241))
       ))
     | cvtUNOP (PreDecrement opt249) = PrettyRep.Ctor ("PreDecrement", SOME 
       (case opt249 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x248 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x248))
       ))
     | cvtUNOP (PostIncrement opt256) = PrettyRep.Ctor ("PostIncrement", SOME 
       (case opt256 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x255 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x255))
       ))
     | cvtUNOP (PostDecrement opt263) = PrettyRep.Ctor ("PostDecrement", SOME 
       (case opt263 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x262 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x262))
       ))
     | cvtUNOP (UnaryPlus opt270) = PrettyRep.Ctor ("UnaryPlus", SOME 
       (case opt270 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x269 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x269))
       ))
     | cvtUNOP (UnaryMinus opt277) = PrettyRep.Ctor ("UnaryMinus", SOME 
       (case opt277 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x276 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x276))
       ))
     | cvtUNOP (BitwiseNot) = PrettyRep.Ctor ("BitwiseNot", NONE)
     | cvtUNOP (LogicalNot) = PrettyRep.Ctor ("LogicalNot", NONE)
     | cvtUNOP (Type) = PrettyRep.Ctor ("Type", NONE)
   and cvtVAR_DEFN_TAG (Const) = PrettyRep.Ctor ("Const", NONE)
     | cvtVAR_DEFN_TAG (Var) = PrettyRep.Ctor ("Var", NONE)
     | cvtVAR_DEFN_TAG (LetVar) = PrettyRep.Ctor ("LetVar", NONE)
     | cvtVAR_DEFN_TAG (LetConst) = PrettyRep.Ctor ("LetConst", NONE)
   and cvtSPECIAL_TY (Any) = PrettyRep.Ctor ("Any", NONE)
     | cvtSPECIAL_TY (Null) = PrettyRep.Ctor ("Null", NONE)
     | cvtSPECIAL_TY (Undefined) = PrettyRep.Ctor ("Undefined", NONE)
     | cvtSPECIAL_TY (VoidType) = PrettyRep.Ctor ("VoidType", NONE)
   and cvtPRAGMA (UseNamespace x294) = PrettyRep.Ctor ("UseNamespace", SOME (cvtEXPR x294))
     | cvtPRAGMA (UseDefaultNamespace x297) = PrettyRep.Ctor ("UseDefaultNamespace", 
          SOME (cvtEXPR x297))
     | cvtPRAGMA (UseNumber x300) = PrettyRep.Ctor ("UseNumber", SOME (cvtNUMBER_TYPE x300))
     | cvtPRAGMA (UseRounding r303) = PrettyRep.Ctor ("UseRounding", SOME (PrettyRep.DecRm r303))
     | cvtPRAGMA (UsePrecision n306) = PrettyRep.Ctor ("UsePrecision", SOME (PrettyRep.Int n306))
     | cvtPRAGMA (UseStrict) = PrettyRep.Ctor ("UseStrict", NONE)
     | cvtPRAGMA (UseStandard) = PrettyRep.Ctor ("UseStandard", NONE)
     | cvtPRAGMA (Import{package=ls312, name=x316, alias=opt318}) = PrettyRep.Ctor ("Import", 
          SOME (PrettyRep.Rec [("package", PrettyRep.List (List.map (fn x311 => 
                                                                           cvtIDENT x311
                                                                    ) ls312)), 
          ("name", cvtIDENT x316), ("alias", 
       (case opt318 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x317 => PrettyRep.Ctor ("SOME", SOME (cvtIDENT x317))
       ))]))
   and cvtFUNC_NAME_KIND (Ordinary) = PrettyRep.Ctor ("Ordinary", NONE)
     | cvtFUNC_NAME_KIND (Operator) = PrettyRep.Ctor ("Operator", NONE)
     | cvtFUNC_NAME_KIND (Get) = PrettyRep.Ctor ("Get", NONE)
     | cvtFUNC_NAME_KIND (Set) = PrettyRep.Ctor ("Set", NONE)
     | cvtFUNC_NAME_KIND (Call) = PrettyRep.Ctor ("Call", NONE)
     | cvtFUNC_NAME_KIND (Has) = PrettyRep.Ctor ("Has", NONE)
   and cvtTY (Ty{expr=x337, ribId=opt339}) = PrettyRep.Ctor ("Ty", SOME (PrettyRep.Rec [("expr", 
          cvtTYPE_EXPR x337), ("ribId", 
       (case opt339 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x338 => PrettyRep.Ctor ("SOME", SOME (cvtRIB_ID x338))
       ))]))
   and cvtCLS (Cls{name=x350, typeParams=ls352, nonnullable=b356, dynamic=b357, 
          extends=opt359, implements=ls364, classRib=x368, instanceRib=x369, 
          instanceInits=x370, constructor=opt372, classType=x376, instanceType=x377}) = 
          PrettyRep.Ctor ("Cls", SOME (PrettyRep.Rec [("name", cvtNAME x350), 
          ("typeParams", PrettyRep.List (List.map (fn x351 => cvtIDENT x351
                                                  ) ls352)), ("nonnullable", 
          PrettyRep.Bool b356), ("dynamic", PrettyRep.Bool b357), ("extends", 
          
       (case opt359 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x358 => PrettyRep.Ctor ("SOME", SOME (cvtTY x358))
       )), ("implements", PrettyRep.List (List.map (fn x363 => cvtTY x363
                                                   ) ls364)), ("classRib", 
          cvtRIB x368), ("instanceRib", cvtRIB x369), ("instanceInits", cvtHEAD x370), 
          ("constructor", 
       (case opt372 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x371 => PrettyRep.Ctor ("SOME", SOME (cvtCTOR x371))
       )), ("classType", cvtTY x376), ("instanceType", cvtTY x377)]))
   and cvtIFACE (Iface{name=x405, typeParams=ls407, nonnullable=b411, extends=ls413, 
          instanceRib=x417, instanceType=x418}) = PrettyRep.Ctor ("Iface", 
          SOME (PrettyRep.Rec [("name", cvtNAME x405), ("typeParams", PrettyRep.List (List.map (fn x406 => 
                                                                                                      cvtIDENT x406
                                                                                               ) ls407)), 
          ("nonnullable", PrettyRep.Bool b411), ("extends", PrettyRep.List (List.map (fn x412 => 
                                                                                            cvtTY x412
                                                                                     ) ls413)), 
          ("instanceRib", cvtRIB x417), ("instanceType", cvtTY x418)]))
   and cvtCTOR (Ctor{settings=x434, superArgs=ls436, func=x440}) = PrettyRep.Ctor ("Ctor", 
          SOME (PrettyRep.Rec [("settings", cvtHEAD x434), ("superArgs", PrettyRep.List (List.map (fn x435 => 
                                                                                                         cvtEXPR x435
                                                                                                  ) ls436)), 
          ("func", cvtFUNC x440)]))
   and cvtFUNC (Func{name=x450, fsig=x451, native=b452, block=opt454, param=x458, 
          defaults=ls460, ty=x464, loc=opt466}) = PrettyRep.Ctor ("Func", SOME (PrettyRep.Rec [("name", 
          cvtFUNC_NAME x450), ("fsig", cvtFUNC_SIG x451), ("native", PrettyRep.Bool b452), 
          ("block", 
       (case opt454 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x453 => PrettyRep.Ctor ("SOME", SOME (cvtBLOCK x453))
       )), ("param", cvtHEAD x458), ("defaults", PrettyRep.List (List.map (fn x459 => 
                                                                                 cvtEXPR x459
                                                                          ) ls460)), 
          ("ty", cvtTY x464), ("loc", 
       (case opt466 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x465 => PrettyRep.Ctor ("SOME", SOME (cvtLOC x465))
       ))]))
   and cvtDEFN (ClassDefn x489) = PrettyRep.Ctor ("ClassDefn", SOME (cvtCLASS_DEFN x489))
     | cvtDEFN (VariableDefn x492) = PrettyRep.Ctor ("VariableDefn", SOME (cvtVAR_DEFN x492))
     | cvtDEFN (FunctionDefn x495) = PrettyRep.Ctor ("FunctionDefn", SOME (cvtFUNC_DEFN x495))
     | cvtDEFN (ConstructorDefn x498) = PrettyRep.Ctor ("ConstructorDefn", 
          SOME (cvtCTOR_DEFN x498))
     | cvtDEFN (InterfaceDefn x501) = PrettyRep.Ctor ("InterfaceDefn", SOME (cvtINTERFACE_DEFN x501))
     | cvtDEFN (NamespaceDefn x504) = PrettyRep.Ctor ("NamespaceDefn", SOME (cvtNAMESPACE_DEFN x504))
     | cvtDEFN (TypeDefn x507) = PrettyRep.Ctor ("TypeDefn", SOME (cvtTYPE_DEFN x507))
   and cvtFUNC_SIG (FunctionSignature{typeParams=ls511, params=x515, paramTypes=ls517, 
          defaults=ls522, ctorInits=opt533, returnType=x537, thisType=opt539, 
          hasRest=b543}) = PrettyRep.Ctor ("FunctionSignature", SOME (PrettyRep.Rec [("typeParams", 
          PrettyRep.List (List.map (fn x510 => cvtIDENT x510
                                   ) ls511)), ("params", cvtBINDINGS x515), 
          ("paramTypes", PrettyRep.List (List.map (fn x516 => cvtTYPE_EXPR x516
                                                  ) ls517)), ("defaults", PrettyRep.List (List.map (fn x521 => 
                                                                                                          cvtEXPR x521
                                                                                                   ) ls522)), 
          ("ctorInits", 
       (case opt533 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME(x526, ls528) => PrettyRep.Ctor ("SOME", SOME (PrettyRep.Tuple [cvtBINDINGS x526, 
            PrettyRep.List (List.map (fn x527 => cvtEXPR x527
                                     ) ls528)]))
       )), ("returnType", cvtTYPE_EXPR x537), ("thisType", 
       (case opt539 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x538 => PrettyRep.Ctor ("SOME", SOME (cvtTYPE_EXPR x538))
       )), ("hasRest", PrettyRep.Bool b543)]))
   and cvtBINDING (Binding{ident=x563, ty=x564}) = PrettyRep.Ctor ("Binding", 
          SOME (PrettyRep.Rec [("ident", cvtBINDING_IDENT x563), ("ty", cvtTYPE_EXPR x564)]))
   and cvtBINDING_IDENT (TempIdent n572) = PrettyRep.Ctor ("TempIdent", SOME (PrettyRep.Int n572))
     | cvtBINDING_IDENT (ParamIdent n575) = PrettyRep.Ctor ("ParamIdent", SOME (PrettyRep.Int n575))
     | cvtBINDING_IDENT (PropIdent x578) = PrettyRep.Ctor ("PropIdent", SOME (cvtIDENT x578))
   and cvtINIT_STEP (InitStep(x581, x582)) = PrettyRep.Ctor ("InitStep", SOME (PrettyRep.Tuple [cvtBINDING_IDENT x581, 
          cvtEXPR x582]))
     | cvtINIT_STEP (AssignStep(x586, x587)) = PrettyRep.Ctor ("AssignStep", 
          SOME (PrettyRep.Tuple [cvtEXPR x586, cvtEXPR x587]))
   and cvtTYPE_EXPR (SpecialType x591) = PrettyRep.Ctor ("SpecialType", SOME (cvtSPECIAL_TY x591))
     | cvtTYPE_EXPR (UnionType ls595) = PrettyRep.Ctor ("UnionType", SOME (PrettyRep.List (List.map (fn x594 => 
                                                                                                           cvtTYPE_EXPR x594
                                                                                                    ) ls595)))
     | cvtTYPE_EXPR (ArrayType ls602) = PrettyRep.Ctor ("ArrayType", SOME (PrettyRep.List (List.map (fn x601 => 
                                                                                                           cvtTYPE_EXPR x601
                                                                                                    ) ls602)))
     | cvtTYPE_EXPR (TypeName x608) = PrettyRep.Ctor ("TypeName", SOME (cvtIDENT_EXPR x608))
     | cvtTYPE_EXPR (ElementTypeRef(x611, n612)) = PrettyRep.Ctor ("ElementTypeRef", 
          SOME (PrettyRep.Tuple [cvtTYPE_EXPR x611, PrettyRep.Int n612]))
     | cvtTYPE_EXPR (FieldTypeRef(x616, x617)) = PrettyRep.Ctor ("FieldTypeRef", 
          SOME (PrettyRep.Tuple [cvtTYPE_EXPR x616, cvtIDENT x617]))
     | cvtTYPE_EXPR (FunctionType x621) = PrettyRep.Ctor ("FunctionType", SOME (cvtFUNC_TYPE x621))
     | cvtTYPE_EXPR (ObjectType ls625) = PrettyRep.Ctor ("ObjectType", SOME (PrettyRep.List (List.map (fn x624 => 
                                                                                                             cvtFIELD_TYPE x624
                                                                                                      ) ls625)))
     | cvtTYPE_EXPR (AppType{base=x631, args=ls633}) = PrettyRep.Ctor ("AppType", 
          SOME (PrettyRep.Rec [("base", cvtTYPE_EXPR x631), ("args", PrettyRep.List (List.map (fn x632 => 
                                                                                                     cvtTYPE_EXPR x632
                                                                                              ) ls633))]))
     | cvtTYPE_EXPR (LamType{params=ls645, body=x649}) = PrettyRep.Ctor ("LamType", 
          SOME (PrettyRep.Rec [("params", PrettyRep.List (List.map (fn x644 => 
                                                                          cvtIDENT x644
                                                                   ) ls645)), 
          ("body", cvtTYPE_EXPR x649)]))
     | cvtTYPE_EXPR (NullableType{expr=x657, nullable=b658}) = PrettyRep.Ctor ("NullableType", 
          SOME (PrettyRep.Rec [("expr", cvtTYPE_EXPR x657), ("nullable", PrettyRep.Bool b658)]))
     | cvtTYPE_EXPR (InstanceType x666) = PrettyRep.Ctor ("InstanceType", SOME (cvtINSTANCE_TYPE x666))
   and cvtSTMT (EmptyStmt) = PrettyRep.Ctor ("EmptyStmt", NONE)
     | cvtSTMT (ExprStmt x670) = PrettyRep.Ctor ("ExprStmt", SOME (cvtEXPR x670))
     | cvtSTMT (InitStmt{kind=x673, ns=opt675, prototype=b679, static=b680, 
          temps=x681, inits=ls683}) = PrettyRep.Ctor ("InitStmt", SOME (PrettyRep.Rec [("kind", 
          cvtVAR_DEFN_TAG x673), ("ns", 
       (case opt675 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x674 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x674))
       )), ("prototype", PrettyRep.Bool b679), ("static", PrettyRep.Bool b680), 
          ("temps", cvtBINDINGS x681), ("inits", PrettyRep.List (List.map (fn x682 => 
                                                                                 cvtINIT_STEP x682
                                                                          ) ls683))]))
     | cvtSTMT (ClassBlock{ns=opt703, ident=x707, name=opt709, block=x713}) = 
          PrettyRep.Ctor ("ClassBlock", SOME (PrettyRep.Rec [("ns", 
       (case opt703 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x702 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x702))
       )), ("ident", cvtIDENT x707), ("name", 
       (case opt709 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x708 => PrettyRep.Ctor ("SOME", SOME (cvtNAME x708))
       )), ("block", cvtBLOCK x713)]))
     | cvtSTMT (ForInStmt x725) = PrettyRep.Ctor ("ForInStmt", SOME (cvtFOR_ENUM_STMT x725))
     | cvtSTMT (ThrowStmt x728) = PrettyRep.Ctor ("ThrowStmt", SOME (cvtEXPR x728))
     | cvtSTMT (ReturnStmt x731) = PrettyRep.Ctor ("ReturnStmt", SOME (cvtEXPR x731))
     | cvtSTMT (BreakStmt opt735) = PrettyRep.Ctor ("BreakStmt", SOME 
       (case opt735 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x734 => PrettyRep.Ctor ("SOME", SOME (cvtIDENT x734))
       ))
     | cvtSTMT (ContinueStmt opt742) = PrettyRep.Ctor ("ContinueStmt", SOME 
       (case opt742 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x741 => PrettyRep.Ctor ("SOME", SOME (cvtIDENT x741))
       ))
     | cvtSTMT (BlockStmt x748) = PrettyRep.Ctor ("BlockStmt", SOME (cvtBLOCK x748))
     | cvtSTMT (LabeledStmt(x751, x752)) = PrettyRep.Ctor ("LabeledStmt", SOME (PrettyRep.Tuple [cvtIDENT x751, 
          cvtSTMT x752]))
     | cvtSTMT (LetStmt x756) = PrettyRep.Ctor ("LetStmt", SOME (cvtBLOCK x756))
     | cvtSTMT (WhileStmt x759) = PrettyRep.Ctor ("WhileStmt", SOME (cvtWHILE_STMT x759))
     | cvtSTMT (DoWhileStmt x762) = PrettyRep.Ctor ("DoWhileStmt", SOME (cvtWHILE_STMT x762))
     | cvtSTMT (ForStmt x765) = PrettyRep.Ctor ("ForStmt", SOME (cvtFOR_STMT x765))
     | cvtSTMT (IfStmt{cnd=x768, thn=x769, els=x770}) = PrettyRep.Ctor ("IfStmt", 
          SOME (PrettyRep.Rec [("cnd", cvtEXPR x768), ("thn", cvtSTMT x769), 
          ("els", cvtSTMT x770)]))
     | cvtSTMT (WithStmt{obj=x780, ty=x781, body=x782}) = PrettyRep.Ctor ("WithStmt", 
          SOME (PrettyRep.Rec [("obj", cvtEXPR x780), ("ty", cvtTY x781), ("body", 
          cvtSTMT x782)]))
     | cvtSTMT (TryStmt{block=x792, catches=ls794, finally=opt799}) = PrettyRep.Ctor ("TryStmt", 
          SOME (PrettyRep.Rec [("block", cvtBLOCK x792), ("catches", PrettyRep.List (List.map (fn x793 => 
                                                                                                     cvtCATCH_CLAUSE x793
                                                                                              ) ls794)), 
          ("finally", 
       (case opt799 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x798 => PrettyRep.Ctor ("SOME", SOME (cvtBLOCK x798))
       ))]))
     | cvtSTMT (SwitchStmt{mode=opt813, cond=x817, labels=ls819, cases=ls824}) = 
          PrettyRep.Ctor ("SwitchStmt", SOME (PrettyRep.Rec [("mode", 
       (case opt813 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x812 => PrettyRep.Ctor ("SOME", SOME (cvtNUMERIC_MODE x812))
       )), ("cond", cvtEXPR x817), ("labels", PrettyRep.List (List.map (fn x818 => 
                                                                              cvtIDENT x818
                                                                       ) ls819)), 
          ("cases", PrettyRep.List (List.map (fn x823 => cvtCASE x823
                                             ) ls824))]))
     | cvtSTMT (SwitchTypeStmt{cond=x839, ty=x840, cases=ls842}) = PrettyRep.Ctor ("SwitchTypeStmt", 
          SOME (PrettyRep.Rec [("cond", cvtEXPR x839), ("ty", cvtTY x840), 
          ("cases", PrettyRep.List (List.map (fn x841 => cvtCATCH_CLAUSE x841
                                             ) ls842))]))
     | cvtSTMT (DXNStmt{expr=x855}) = PrettyRep.Ctor ("DXNStmt", SOME (PrettyRep.Rec [("expr", 
          cvtEXPR x855)]))
   and cvtEXPR (TernaryExpr(x861, x862, x863)) = PrettyRep.Ctor ("TernaryExpr", 
          SOME (PrettyRep.Tuple [cvtEXPR x861, cvtEXPR x862, cvtEXPR x863]))
     | cvtEXPR (BinaryExpr(x867, x868, x869)) = PrettyRep.Ctor ("BinaryExpr", 
          SOME (PrettyRep.Tuple [cvtBINOP x867, cvtEXPR x868, cvtEXPR x869]))
     | cvtEXPR (BinaryTypeExpr(x873, x874, x875)) = PrettyRep.Ctor ("BinaryTypeExpr", 
          SOME (PrettyRep.Tuple [cvtBINTYPEOP x873, cvtEXPR x874, cvtTY x875]))
     | cvtEXPR (ExpectedTypeExpr(x879, x880)) = PrettyRep.Ctor ("ExpectedTypeExpr", 
          SOME (PrettyRep.Tuple [cvtTYPE_EXPR x879, cvtEXPR x880]))
     | cvtEXPR (UnaryExpr(x884, x885)) = PrettyRep.Ctor ("UnaryExpr", SOME (PrettyRep.Tuple [cvtUNOP x884, 
          cvtEXPR x885]))
     | cvtEXPR (TypeExpr x889) = PrettyRep.Ctor ("TypeExpr", SOME (cvtTY x889))
     | cvtEXPR (ThisExpr) = PrettyRep.Ctor ("ThisExpr", NONE)
     | cvtEXPR (YieldExpr opt894) = PrettyRep.Ctor ("YieldExpr", SOME 
       (case opt894 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x893 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x893))
       ))
     | cvtEXPR (SuperExpr opt901) = PrettyRep.Ctor ("SuperExpr", SOME 
       (case opt901 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x900 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x900))
       ))
     | cvtEXPR (LiteralExpr x907) = PrettyRep.Ctor ("LiteralExpr", SOME (cvtLITERAL x907))
     | cvtEXPR (CallExpr{func=x910, actuals=ls912}) = PrettyRep.Ctor ("CallExpr", 
          SOME (PrettyRep.Rec [("func", cvtEXPR x910), ("actuals", PrettyRep.List (List.map (fn x911 => 
                                                                                                   cvtEXPR x911
                                                                                            ) ls912))]))
     | cvtEXPR (ApplyTypeExpr{expr=x923, actuals=ls925}) = PrettyRep.Ctor ("ApplyTypeExpr", 
          SOME (PrettyRep.Rec [("expr", cvtEXPR x923), ("actuals", PrettyRep.List (List.map (fn x924 => 
                                                                                                   cvtTY x924
                                                                                            ) ls925))]))
     | cvtEXPR (LetExpr{defs=x936, body=x937, head=opt939}) = PrettyRep.Ctor ("LetExpr", 
          SOME (PrettyRep.Rec [("defs", cvtBINDINGS x936), ("body", cvtEXPR x937), 
          ("head", 
       (case opt939 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x938 => PrettyRep.Ctor ("SOME", SOME (cvtHEAD x938))
       ))]))
     | cvtEXPR (NewExpr{obj=x952, actuals=ls954}) = PrettyRep.Ctor ("NewExpr", 
          SOME (PrettyRep.Rec [("obj", cvtEXPR x952), ("actuals", PrettyRep.List (List.map (fn x953 => 
                                                                                                  cvtEXPR x953
                                                                                           ) ls954))]))
     | cvtEXPR (ObjectRef{base=x965, ident=x966, loc=opt968}) = PrettyRep.Ctor ("ObjectRef", 
          SOME (PrettyRep.Rec [("base", cvtEXPR x965), ("ident", cvtIDENT_EXPR x966), 
          ("loc", 
       (case opt968 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x967 => PrettyRep.Ctor ("SOME", SOME (cvtLOC x967))
       ))]))
     | cvtEXPR (LexicalRef{ident=x981, loc=opt983}) = PrettyRep.Ctor ("LexicalRef", 
          SOME (PrettyRep.Rec [("ident", cvtIDENT_EXPR x981), ("loc", 
       (case opt983 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x982 => PrettyRep.Ctor ("SOME", SOME (cvtLOC x982))
       ))]))
     | cvtEXPR (SetExpr(x994, x995, x996)) = PrettyRep.Ctor ("SetExpr", SOME (PrettyRep.Tuple [cvtASSIGNOP x994, 
          cvtEXPR x995, cvtEXPR x996]))
     | cvtEXPR (ListExpr ls1001) = PrettyRep.Ctor ("ListExpr", SOME (PrettyRep.List (List.map (fn x1000 => 
                                                                                                     cvtEXPR x1000
                                                                                              ) ls1001)))
     | cvtEXPR (InitExpr(x1007, x1008, x1009)) = PrettyRep.Ctor ("InitExpr", 
          SOME (PrettyRep.Tuple [cvtINIT_TARGET x1007, cvtHEAD x1008, cvtINITS x1009]))
     | cvtEXPR (SliceExpr(x1013, x1014, x1015)) = PrettyRep.Ctor ("SliceExpr", 
          SOME (PrettyRep.Tuple [cvtEXPR x1013, cvtEXPR x1014, cvtEXPR x1015]))
     | cvtEXPR (GetTemp n1019) = PrettyRep.Ctor ("GetTemp", SOME (PrettyRep.Int n1019))
     | cvtEXPR (GetParam n1022) = PrettyRep.Ctor ("GetParam", SOME (PrettyRep.Int n1022))
   and cvtINIT_TARGET (Hoisted) = PrettyRep.Ctor ("Hoisted", NONE)
     | cvtINIT_TARGET (Local) = PrettyRep.Ctor ("Local", NONE)
     | cvtINIT_TARGET (Prototype) = PrettyRep.Ctor ("Prototype", NONE)
   and cvtFIXTURE_NAME (TempName n1028) = PrettyRep.Ctor ("TempName", SOME (PrettyRep.Int n1028))
     | cvtFIXTURE_NAME (PropName x1031) = PrettyRep.Ctor ("PropName", SOME (cvtNAME x1031))
   and cvtIDENT_EXPR (Identifier{ident=x1034, openNamespaces=ls1040}) = PrettyRep.Ctor ("Identifier", 
          SOME (PrettyRep.Rec [("ident", cvtIDENT x1034), ("openNamespaces", 
          PrettyRep.List (List.map (fn ls1036 => PrettyRep.List (List.map (fn x1035 => 
                                                                                 cvtNAMESPACE x1035
                                                                          ) ls1036)
                                   ) ls1040))]))
     | cvtIDENT_EXPR (QualifiedExpression{qual=x1051, expr=x1052}) = PrettyRep.Ctor ("QualifiedExpression", 
          SOME (PrettyRep.Rec [("qual", cvtEXPR x1051), ("expr", cvtEXPR x1052)]))
     | cvtIDENT_EXPR (AttributeIdentifier x1060) = PrettyRep.Ctor ("AttributeIdentifier", 
          SOME (cvtIDENT_EXPR x1060))
     | cvtIDENT_EXPR (ExpressionIdentifier{expr=x1063, openNamespaces=ls1069}) = 
          PrettyRep.Ctor ("ExpressionIdentifier", SOME (PrettyRep.Rec [("expr", 
          cvtEXPR x1063), ("openNamespaces", PrettyRep.List (List.map (fn ls1065 => 
                                                                             PrettyRep.List (List.map (fn x1064 => 
                                                                                                             cvtNAMESPACE x1064
                                                                                                      ) ls1065)
                                                                      ) ls1069))]))
     | cvtIDENT_EXPR (QualifiedIdentifier{qual=x1080, ident=s1081}) = PrettyRep.Ctor ("QualifiedIdentifier", 
          SOME (PrettyRep.Rec [("qual", cvtEXPR x1080), ("ident", PrettyRep.UniStr s1081)]))
     | cvtIDENT_EXPR (UnresolvedPath(ls1090, x1094)) = PrettyRep.Ctor ("UnresolvedPath", 
          SOME (PrettyRep.Tuple [PrettyRep.List (List.map (fn x1089 => cvtIDENT x1089
                                                          ) ls1090), cvtIDENT_EXPR x1094]))
     | cvtIDENT_EXPR (WildcardIdentifier) = PrettyRep.Ctor ("WildcardIdentifier", 
          NONE)
   and cvtLITERAL (LiteralNull) = PrettyRep.Ctor ("LiteralNull", NONE)
     | cvtLITERAL (LiteralUndefined) = PrettyRep.Ctor ("LiteralUndefined", 
          NONE)
     | cvtLITERAL (LiteralContextualDecimal s1101) = PrettyRep.Ctor ("LiteralContextualDecimal", 
          SOME (PrettyRep.String s1101))
     | cvtLITERAL (LiteralContextualDecimalInteger s1104) = PrettyRep.Ctor ("LiteralContextualDecimalInteger", 
          SOME (PrettyRep.String s1104))
     | cvtLITERAL (LiteralContextualHexInteger s1107) = PrettyRep.Ctor ("LiteralContextualHexInteger", 
          SOME (PrettyRep.String s1107))
     | cvtLITERAL (LiteralDouble r1110) = PrettyRep.Ctor ("LiteralDouble", 
          SOME (PrettyRep.Real64 r1110))
     | cvtLITERAL (LiteralDecimal d1113) = PrettyRep.Ctor ("LiteralDecimal", 
          SOME (PrettyRep.Dec d1113))
     | cvtLITERAL (LiteralInt i1116) = PrettyRep.Ctor ("LiteralInt", SOME (PrettyRep.Int32 i1116))
     | cvtLITERAL (LiteralUInt u1119) = PrettyRep.Ctor ("LiteralUInt", SOME (PrettyRep.UInt32 u1119))
     | cvtLITERAL (LiteralBoolean b1122) = PrettyRep.Ctor ("LiteralBoolean", 
          SOME (PrettyRep.Bool b1122))
     | cvtLITERAL (LiteralString s1125) = PrettyRep.Ctor ("LiteralString", 
          SOME (PrettyRep.UniStr s1125))
     | cvtLITERAL (LiteralArray{exprs=ls1129, ty=opt1134}) = PrettyRep.Ctor ("LiteralArray", 
          SOME (PrettyRep.Rec [("exprs", PrettyRep.List (List.map (fn x1128 => 
                                                                         cvtEXPR x1128
                                                                  ) ls1129)), 
          ("ty", 
       (case opt1134 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1133 => PrettyRep.Ctor ("SOME", SOME (cvtTY x1133))
       ))]))
     | cvtLITERAL (LiteralXML ls1146) = PrettyRep.Ctor ("LiteralXML", SOME (PrettyRep.List (List.map (fn x1145 => 
                                                                                                            cvtEXPR x1145
                                                                                                     ) ls1146)))
     | cvtLITERAL (LiteralNamespace x1152) = PrettyRep.Ctor ("LiteralNamespace", 
          SOME (cvtNAMESPACE x1152))
     | cvtLITERAL (LiteralObject{expr=ls1156, ty=opt1161}) = PrettyRep.Ctor ("LiteralObject", 
          SOME (PrettyRep.Rec [("expr", PrettyRep.List (List.map (fn x1155 => 
                                                                        cvtFIELD x1155
                                                                 ) ls1156)), 
          ("ty", 
       (case opt1161 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1160 => PrettyRep.Ctor ("SOME", SOME (cvtTY x1160))
       ))]))
     | cvtLITERAL (LiteralFunction x1172) = PrettyRep.Ctor ("LiteralFunction", 
          SOME (cvtFUNC x1172))
     | cvtLITERAL (LiteralRegExp{str=s1175}) = PrettyRep.Ctor ("LiteralRegExp", 
          SOME (PrettyRep.Rec [("str", PrettyRep.UniStr s1175)]))
   and cvtBLOCK (Block x1181) = PrettyRep.Ctor ("Block", SOME (cvtDIRECTIVES x1181))
   and cvtFIXTURE (NamespaceFixture x1184) = PrettyRep.Ctor ("NamespaceFixture", 
          SOME (cvtNAMESPACE x1184))
     | cvtFIXTURE (ClassFixture x1187) = PrettyRep.Ctor ("ClassFixture", SOME (cvtCLS x1187))
     | cvtFIXTURE (InterfaceFixture x1190) = PrettyRep.Ctor ("InterfaceFixture", 
          SOME (cvtIFACE x1190))
     | cvtFIXTURE (TypeVarFixture) = PrettyRep.Ctor ("TypeVarFixture", NONE)
     | cvtFIXTURE (TypeFixture x1194) = PrettyRep.Ctor ("TypeFixture", SOME (cvtTY x1194))
     | cvtFIXTURE (MethodFixture{func=x1197, ty=x1198, readOnly=b1199, override=b1200, 
          final=b1201}) = PrettyRep.Ctor ("MethodFixture", SOME (PrettyRep.Rec [("func", 
          cvtFUNC x1197), ("ty", cvtTY x1198), ("readOnly", PrettyRep.Bool b1199), 
          ("override", PrettyRep.Bool b1200), ("final", PrettyRep.Bool b1201)]))
     | cvtFIXTURE (ValFixture{ty=x1215, readOnly=b1216}) = PrettyRep.Ctor ("ValFixture", 
          SOME (PrettyRep.Rec [("ty", cvtTY x1215), ("readOnly", PrettyRep.Bool b1216)]))
     | cvtFIXTURE (VirtualValFixture{ty=x1224, getter=opt1226, setter=opt1231}) = 
          PrettyRep.Ctor ("VirtualValFixture", SOME (PrettyRep.Rec [("ty", 
          cvtTY x1224), ("getter", 
       (case opt1226 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1225 => PrettyRep.Ctor ("SOME", SOME (cvtFUNC x1225))
       )), ("setter", 
       (case opt1231 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1230 => PrettyRep.Ctor ("SOME", SOME (cvtFUNC x1230))
       ))]))
     | cvtFIXTURE (InheritedFixture{baseName=x1244, baseTypeArgs=ls1246}) = 
          PrettyRep.Ctor ("InheritedFixture", SOME (PrettyRep.Rec [("baseName", 
          cvtNAME x1244), ("baseTypeArgs", PrettyRep.List (List.map (fn x1245 => 
                                                                           cvtTY x1245
                                                                    ) ls1246))]))
   and cvtHEAD (Head(x1257, x1258)) = PrettyRep.Ctor ("Head", SOME (PrettyRep.Tuple [cvtRIB x1257, 
          cvtINITS x1258]))
   and cvtBINDINGS (ls1263, ls1268) = PrettyRep.Tuple [PrettyRep.List (List.map (fn x1262 => 
                                                                                       cvtBINDING x1262
                                                                                ) ls1263), 
          PrettyRep.List (List.map (fn x1267 => cvtINIT_STEP x1267
                                   ) ls1268)]
   and cvtRIB ls1276 = PrettyRep.List (List.map (fn (x1273, x1274) => PrettyRep.Tuple [cvtFIXTURE_NAME x1273, 
                                                       cvtFIXTURE x1274]
                                                ) ls1276)
   and cvtRIBS ls1281 = PrettyRep.List (List.map (fn x1280 => cvtRIB x1280
                                                 ) ls1281)
   and cvtINITS ls1288 = PrettyRep.List (List.map (fn (x1285, x1286) => PrettyRep.Tuple [cvtFIXTURE_NAME x1285, 
                                                         cvtEXPR x1286]
                                                  ) ls1288)
   and cvtINSTANCE_TYPE {name=x1292, typeArgs=ls1294, nonnullable=b1298, superTypes=ls1300, 
          ty=x1304, dynamic=b1305} = PrettyRep.Rec [("name", cvtNAME x1292), 
          ("typeArgs", PrettyRep.List (List.map (fn x1293 => cvtTYPE_EXPR x1293
                                                ) ls1294)), ("nonnullable", 
          PrettyRep.Bool b1298), ("superTypes", PrettyRep.List (List.map (fn x1299 => 
                                                                                cvtTYPE_EXPR x1299
                                                                         ) ls1300)), 
          ("ty", cvtTYPE_EXPR x1304), ("dynamic", PrettyRep.Bool b1305)]
   and cvtFIELD {kind=x1319, name=x1320, init=x1321} = PrettyRep.Rec [("kind", 
          cvtVAR_DEFN_TAG x1319), ("name", cvtIDENT_EXPR x1320), ("init", cvtEXPR x1321)]
   and cvtFIELD_TYPE {name=x1329, ty=x1330} = PrettyRep.Rec [("name", cvtIDENT x1329), 
          ("ty", cvtTYPE_EXPR x1330)]
   and cvtFUNC_TYPE {params=ls1337, result=x1341, thisType=opt1343, hasRest=b1347, 
          minArgs=n1348} = PrettyRep.Rec [("params", PrettyRep.List (List.map (fn x1336 => 
                                                                                     cvtTYPE_EXPR x1336
                                                                              ) ls1337)), 
          ("result", cvtTYPE_EXPR x1341), ("thisType", 
       (case opt1343 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1342 => PrettyRep.Ctor ("SOME", SOME (cvtTYPE_EXPR x1342))
       )), ("hasRest", PrettyRep.Bool b1347), ("minArgs", PrettyRep.Int n1348)]
   and cvtFUNC_DEFN {kind=x1360, ns=opt1362, final=b1366, override=b1367, prototype=b1368, 
          static=b1369, func=x1370} = PrettyRep.Rec [("kind", cvtVAR_DEFN_TAG x1360), 
          ("ns", 
       (case opt1362 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1361 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1361))
       )), ("final", PrettyRep.Bool b1366), ("override", PrettyRep.Bool b1367), 
          ("prototype", PrettyRep.Bool b1368), ("static", PrettyRep.Bool b1369), 
          ("func", cvtFUNC x1370)]
   and cvtCTOR_DEFN x1386 = cvtCTOR x1386
   and cvtVAR_DEFN {kind=x1387, ns=opt1389, static=b1393, prototype=b1394, 
          bindings=(ls1396, ls1401)} = PrettyRep.Rec [("kind", cvtVAR_DEFN_TAG x1387), 
          ("ns", 
       (case opt1389 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1388 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1388))
       )), ("static", PrettyRep.Bool b1393), ("prototype", PrettyRep.Bool b1394), 
          ("bindings", PrettyRep.Tuple [PrettyRep.List (List.map (fn x1395 => 
                                                                        cvtBINDING x1395
                                                                 ) ls1396), 
          PrettyRep.List (List.map (fn x1400 => cvtINIT_STEP x1400
                                   ) ls1401)])]
   and cvtNAMESPACE_DEFN {ident=x1417, ns=opt1419, init=opt1424} = PrettyRep.Rec [("ident", 
          cvtIDENT x1417), ("ns", 
       (case opt1419 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1418 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1418))
       )), ("init", 
       (case opt1424 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1423 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1423))
       ))]
   and cvtCLASS_DEFN {ns=opt1436, ident=x1440, nonnullable=b1441, dynamic=b1442, 
          final=b1443, params=ls1445, extends=opt1450, implements=ls1455, classDefns=ls1460, 
          instanceDefns=ls1465, instanceStmts=ls1470, ctorDefn=opt1475} = PrettyRep.Rec [("ns", 
          
       (case opt1436 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1435 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1435))
       )), ("ident", cvtIDENT x1440), ("nonnullable", PrettyRep.Bool b1441), 
          ("dynamic", PrettyRep.Bool b1442), ("final", PrettyRep.Bool b1443), 
          ("params", PrettyRep.List (List.map (fn x1444 => cvtIDENT x1444
                                              ) ls1445)), ("extends", 
       (case opt1450 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1449 => PrettyRep.Ctor ("SOME", SOME (cvtTYPE_EXPR x1449))
       )), ("implements", PrettyRep.List (List.map (fn x1454 => cvtTYPE_EXPR x1454
                                                   ) ls1455)), ("classDefns", 
          PrettyRep.List (List.map (fn x1459 => cvtDEFN x1459
                                   ) ls1460)), ("instanceDefns", PrettyRep.List (List.map (fn x1464 => 
                                                                                                 cvtDEFN x1464
                                                                                          ) ls1465)), 
          ("instanceStmts", PrettyRep.List (List.map (fn x1469 => cvtSTMT x1469
                                                     ) ls1470)), ("ctorDefn", 
          
       (case opt1475 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1474 => PrettyRep.Ctor ("SOME", SOME (cvtCTOR x1474))
       ))]
   and cvtINTERFACE_DEFN {ident=x1504, ns=opt1506, nonnullable=b1510, params=ls1512, 
          extends=ls1517, instanceDefns=ls1522} = PrettyRep.Rec [("ident", 
          cvtIDENT x1504), ("ns", 
       (case opt1506 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1505 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1505))
       )), ("nonnullable", PrettyRep.Bool b1510), ("params", PrettyRep.List (List.map (fn x1511 => 
                                                                                             cvtIDENT x1511
                                                                                      ) ls1512)), 
          ("extends", PrettyRep.List (List.map (fn x1516 => cvtTYPE_EXPR x1516
                                               ) ls1517)), ("instanceDefns", 
          PrettyRep.List (List.map (fn x1521 => cvtDEFN x1521
                                   ) ls1522))]
   and cvtTYPE_DEFN {ident=x1539, ns=opt1541, init=x1545} = PrettyRep.Rec [("ident", 
          cvtIDENT x1539), ("ns", 
       (case opt1541 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1540 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1540))
       )), ("init", cvtTYPE_EXPR x1545)]
   and cvtFOR_ENUM_STMT {isEach=b1553, defn=opt1584, obj=x1588, rib=opt1596, 
          next=x1600, labels=ls1602, body=x1606} = PrettyRep.Rec [("isEach", 
          PrettyRep.Bool b1553), ("defn", 
       (case opt1584 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME{kind=x1554, ns=opt1556, static=b1560, prototype=b1561, bindings=(ls1563, 
            ls1568)} => PrettyRep.Ctor ("SOME", SOME (PrettyRep.Rec [("kind", 
            cvtVAR_DEFN_TAG x1554), ("ns", 
         (case opt1556 of
           NONE => PrettyRep.Ctor ("NONE", NONE)
         | SOME x1555 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1555))
         )), ("static", PrettyRep.Bool b1560), ("prototype", PrettyRep.Bool b1561), 
            ("bindings", PrettyRep.Tuple [PrettyRep.List (List.map (fn x1562 => 
                                                                          cvtBINDING x1562
                                                                   ) ls1563), 
            PrettyRep.List (List.map (fn x1567 => cvtINIT_STEP x1567
                                     ) ls1568)])]))
       )), ("obj", cvtEXPR x1588), ("rib", 
       (case opt1596 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME ls1592 => PrettyRep.Ctor ("SOME", SOME (PrettyRep.List (List.map (fn (x1589, 
                                                                                      x1590) => 
                                                                                      PrettyRep.Tuple [cvtFIXTURE_NAME x1589, 
                                                                                      cvtFIXTURE x1590]
                                                                               ) ls1592)))
       )), ("next", cvtSTMT x1600), ("labels", PrettyRep.List (List.map (fn x1601 => 
                                                                               cvtIDENT x1601
                                                                        ) ls1602)), 
          ("body", cvtSTMT x1606)]
   and cvtFOR_STMT {rib=opt1629, defn=opt1663, init=ls1668, cond=x1672, update=x1673, 
          labels=ls1675, body=x1679} = PrettyRep.Rec [("rib", 
       (case opt1629 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME ls1625 => PrettyRep.Ctor ("SOME", SOME (PrettyRep.List (List.map (fn (x1622, 
                                                                                      x1623) => 
                                                                                      PrettyRep.Tuple [cvtFIXTURE_NAME x1622, 
                                                                                      cvtFIXTURE x1623]
                                                                               ) ls1625)))
       )), ("defn", 
       (case opt1663 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME{kind=x1633, ns=opt1635, static=b1639, prototype=b1640, bindings=(ls1642, 
            ls1647)} => PrettyRep.Ctor ("SOME", SOME (PrettyRep.Rec [("kind", 
            cvtVAR_DEFN_TAG x1633), ("ns", 
         (case opt1635 of
           NONE => PrettyRep.Ctor ("NONE", NONE)
         | SOME x1634 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1634))
         )), ("static", PrettyRep.Bool b1639), ("prototype", PrettyRep.Bool b1640), 
            ("bindings", PrettyRep.Tuple [PrettyRep.List (List.map (fn x1641 => 
                                                                          cvtBINDING x1641
                                                                   ) ls1642), 
            PrettyRep.List (List.map (fn x1646 => cvtINIT_STEP x1646
                                     ) ls1647)])]))
       )), ("init", PrettyRep.List (List.map (fn x1667 => cvtSTMT x1667
                                             ) ls1668)), ("cond", cvtEXPR x1672), 
          ("update", cvtEXPR x1673), ("labels", PrettyRep.List (List.map (fn x1674 => 
                                                                                cvtIDENT x1674
                                                                         ) ls1675)), 
          ("body", cvtSTMT x1679)]
   and cvtWHILE_STMT {cond=x1695, rib=opt1703, body=x1707, labels=ls1709} = 
          PrettyRep.Rec [("cond", cvtEXPR x1695), ("rib", 
       (case opt1703 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME ls1699 => PrettyRep.Ctor ("SOME", SOME (PrettyRep.List (List.map (fn (x1696, 
                                                                                      x1697) => 
                                                                                      PrettyRep.Tuple [cvtFIXTURE_NAME x1696, 
                                                                                      cvtFIXTURE x1697]
                                                                               ) ls1699)))
       )), ("body", cvtSTMT x1707), ("labels", PrettyRep.List (List.map (fn x1708 => 
                                                                               cvtIDENT x1708
                                                                        ) ls1709))]
   and cvtDIRECTIVES {pragmas=ls1723, defns=ls1728, head=opt1733, body=ls1738, 
          loc=opt1743} = PrettyRep.Rec [("pragmas", PrettyRep.List (List.map (fn x1722 => 
                                                                                    cvtPRAGMA x1722
                                                                             ) ls1723)), 
          ("defns", PrettyRep.List (List.map (fn x1727 => cvtDEFN x1727
                                             ) ls1728)), ("head", 
       (case opt1733 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1732 => PrettyRep.Ctor ("SOME", SOME (cvtHEAD x1732))
       )), ("body", PrettyRep.List (List.map (fn x1737 => cvtSTMT x1737
                                             ) ls1738)), ("loc", 
       (case opt1743 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1742 => PrettyRep.Ctor ("SOME", SOME (cvtLOC x1742))
       ))]
   and cvtCASE {label=opt1759, inits=opt1770, body=x1774} = PrettyRep.Rec [("label", 
          
       (case opt1759 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1758 => PrettyRep.Ctor ("SOME", SOME (cvtEXPR x1758))
       )), ("inits", 
       (case opt1770 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME ls1766 => PrettyRep.Ctor ("SOME", SOME (PrettyRep.List (List.map (fn (x1763, 
                                                                                      x1764) => 
                                                                                      PrettyRep.Tuple [cvtFIXTURE_NAME x1763, 
                                                                                      cvtEXPR x1764]
                                                                               ) ls1766)))
       )), ("body", cvtBLOCK x1774)]
   and cvtCATCH_CLAUSE {bindings=(ls1783, ls1788), ty=x1793, rib=opt1801, inits=opt1812, 
          block=x1816} = PrettyRep.Rec [("bindings", PrettyRep.Tuple [PrettyRep.List (List.map (fn x1782 => 
                                                                                                      cvtBINDING x1782
                                                                                               ) ls1783), 
          PrettyRep.List (List.map (fn x1787 => cvtINIT_STEP x1787
                                   ) ls1788)]), ("ty", cvtTY x1793), ("rib", 
          
       (case opt1801 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME ls1797 => PrettyRep.Ctor ("SOME", SOME (PrettyRep.List (List.map (fn (x1794, 
                                                                                      x1795) => 
                                                                                      PrettyRep.Tuple [cvtFIXTURE_NAME x1794, 
                                                                                      cvtFIXTURE x1795]
                                                                               ) ls1797)))
       )), ("inits", 
       (case opt1812 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME ls1808 => PrettyRep.Ctor ("SOME", SOME (PrettyRep.List (List.map (fn (x1805, 
                                                                                      x1806) => 
                                                                                      PrettyRep.Tuple [cvtFIXTURE_NAME x1805, 
                                                                                      cvtEXPR x1806]
                                                                               ) ls1808)))
       )), ("block", cvtBLOCK x1816)]
   and cvtFUNC_NAME {kind=x1828, ident=x1829} = PrettyRep.Rec [("kind", cvtFUNC_NAME_KIND x1828), 
          ("ident", cvtIDENT x1829)]
   and cvtVIRTUAL_VAL_FIXTURE {ty=x1835, getter=opt1837, setter=opt1842} = 
          PrettyRep.Rec [("ty", cvtTY x1835), ("getter", 
       (case opt1837 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1836 => PrettyRep.Ctor ("SOME", SOME (cvtFUNC x1836))
       )), ("setter", 
       (case opt1842 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1841 => PrettyRep.Ctor ("SOME", SOME (cvtFUNC x1841))
       ))]
   and cvtFRAGMENT (Unit{name=opt1854, fragments=ls1859}) = PrettyRep.Ctor ("Unit", 
          SOME (PrettyRep.Rec [("name", 
       (case opt1854 of
         NONE => PrettyRep.Ctor ("NONE", NONE)
       | SOME x1853 => PrettyRep.Ctor ("SOME", SOME (cvtUNIT_NAME x1853))
       )), ("fragments", PrettyRep.List (List.map (fn x1858 => cvtFRAGMENT x1858
                                                  ) ls1859))]))
     | cvtFRAGMENT (Package{name=ls1871, fragments=ls1876}) = PrettyRep.Ctor ("Package", 
          SOME (PrettyRep.Rec [("name", PrettyRep.List (List.map (fn x1870 => 
                                                                        cvtIDENT x1870
                                                                 ) ls1871)), 
          ("fragments", PrettyRep.List (List.map (fn x1875 => cvtFRAGMENT x1875
                                                 ) ls1876))]))
     | cvtFRAGMENT (Anon x1887) = PrettyRep.Ctor ("Anon", SOME (cvtBLOCK x1887))
end

