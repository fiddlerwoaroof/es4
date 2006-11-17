
structure Parser = struct

open Token

exception ParseError

datatype alpha =
    ALLOWLIST
  | NOLIST

datatype beta =
    ALLOWIN
  | NOIN

datatype omega =
    ABBREV
  | NOSHORTIF
  | FULL

fun log ss = 
    (TextIO.print "log: "; 
     List.app TextIO.print ss; 
     TextIO.print "\n")

val trace_on = true

fun trace ss =
	if trace_on then log ss else ()
(*

Identifier    
    Identifier
    ContextuallyReservedIdentifier
*)

fun identifier ts =
    let
    in case ts of
        IDENTIFIER(nm) :: tr => (tr,nm)
	  | CALL :: tr => (tr,"call")
      | DEBUGGER :: tr => (tr,"debugger")
      | DECIMAL :: tr => (tr,"decimal")
      | DOUBLE :: tr => (tr,"double")
      | DYNAMIC :: tr => (tr,"dynamic")
      | EACH :: tr => (tr,"each")
      | FINAL :: tr => (tr,"final")
      | GET :: tr => (tr,"get")
      | GOTO :: tr => (tr,"goto")
      | INCLUDE :: tr => (tr,"include")
      | INT :: tr => (tr,"int")
      | NAMESPACE :: tr => (tr,"namespace")
      | NATIVE :: tr => (tr,"native")
      | NUMBER :: tr => (tr,"number")
      | OVERRIDE :: tr => (tr,"override")
      | PROTOTYPE :: tr => (tr,"prototype")
      | ROUNDING :: tr => (tr,"rounding")
      | STANDARD :: tr => (tr,"standard")
      | STRICT :: tr => (tr,"strict")
      | UINT :: tr => (tr,"uint")
      | SET :: tr => (tr,"set")
      | STATIC :: tr => (tr,"static")
      | TYPE :: tr => (tr,"type")
      | XML :: tr => (tr,"xml")
      | YIELD :: tr => (tr,"yield")
      | _ => raise ParseError
    end

(*
    PropertyIdentifier ->
        Identifier
        *
*)

and propertyIdentifier ts =
    let 
        val _ = trace([">> propertyIdentifier with next=",tokenname(hd(ts))]) 
    in case ts of
        MULT :: tr => (tr,"*")
      | _ => 
            let
                val (ts1,nd1) = identifier ts
            in
                (trace(["<< propertyIdentifier with next=",tokenname(hd(ts1))]);(ts1,nd1)) 
            end
    end

(*
    Qualifier
        ReservedNamespace
        PropertyIdentifier
*)

and qualifier ts =
    let
    in case ts of
        (INTERNAL :: _ | INTRINSIC :: _ | PRIVATE :: _ | PROTECTED :: _ | PUBLIC :: _) => 
          let
              val (ts1,nd1) = reservedNamespace (ts)
          in
              (ts1,Ast.LiteralExpr(nd1))
          end
      | _ => 
          let
              val (ts1,nd1) = propertyIdentifier (ts)
          in
              (ts1,Ast.QualIdent({qual=NONE, ident=nd1, opennss=[Ast.Namespace (Ast.PUBLIC,"")]}))
          end
    end

and reservedNamespace ts =
    let val _ = trace([">> reservedNamespace with next=",tokenname(hd(ts))])
    in case ts of
        INTERNAL :: tr => 
			(tr, Ast.LiteralNamespace(Ast.Namespace (Ast.INTERNAL,"put package name here")))
      | INTRINSIC :: tr => 
			(tr, Ast.LiteralNamespace(Ast.Namespace (Ast.INTRINSIC,"")))
      | PRIVATE :: tr => 
			(tr, Ast.LiteralNamespace(Ast.Namespace (Ast.PRIVATE,"put class name here")))
      | PROTECTED :: tr => 
			(tr, Ast.LiteralNamespace(Ast.Namespace (Ast.PROTECTED,"put class name here")))
      | PUBLIC :: tr => 
			(tr, Ast.LiteralNamespace(Ast.Namespace (Ast.PUBLIC,"")))
      | _ => raise ParseError
    end

(*
	SimpleQualifiedIdentifier    
	    PropertyIdentifier
	    Qualifier  ::  PropertyIdentifier
	    Qualifier  ::  ReservedIdentifier
	    Qualifier  ::  Brackets

	ExpressionQualifiedIdentifer    
	    ParenListExpression  ::  PropertyIdentifier
	    ParenListExpression  ::  ReservedIdentifier
	    ParenListExpression  ::  Brackets

	left factored: 

	SimpleQualifiedIdentifier
    	ReservedNamespace :: QualifiedIdentifierPrime
	    PropertyIdentifier :: QualifiedIdentifierPrime
    	PropertyIdentifier

	ExpressionQualifiedIdentifer    
    	ParenListExpression  ::  QualifiedIdentifierPrime

	QualifiedIdentifierPrime
    	PropertyIdentifier
	    ReservedIdentifier
    	Brackets
*)

and simpleQualifiedIdentifier ts =
    let val _ = trace([">> simpleQualifiedIdentifier with next=",tokenname(hd(ts))]) 
    in 
    case ts of
        (INTERNAL :: _ | INTRINSIC :: _ | PRIVATE :: _ | PROTECTED :: _ | PUBLIC :: _) => 
          let 
              val (ts1, nd1) = reservedNamespace(ts)
          in case ts1 of
              DOUBLECOLON :: ts2 => qualifiedIdentifierPrime(ts2,Ast.LiteralExpr(nd1))
            | _ => raise ParseError
          end
      | _ => 
          	let
              	val (ts1, nd1) = propertyIdentifier(ts)
          	in case ts1 of
              	DOUBLECOLON :: _ => 
					qualifiedIdentifierPrime(tl ts1,Ast.Ref ({base=NONE,ident=Ast.Identifier nd1}))
              | _ => ( trace(["<< simpleQualifiedIdentifier with next=",tokenname(hd(ts1))]);
					   (ts1,Ast.Identifier nd1) )
          end
    end

and expressionQualifiedIdentifier (ts) =
    let 
		val (ts1,nd1) = parenListExpression(ts)
    in 
    case ts1 of
        DOUBLECOLON :: ts2 => qualifiedIdentifierPrime(ts2,nd1)
      | _ => raise ParseError
    end

and reservedOrPropertyIdentifier ts =
    case isreserved(hd ts) of
        true => (tl ts, tokenname(hd ts))
      | false => propertyIdentifier(ts)

and qualifiedIdentifierPrime (ts1, nd1) : (token list * Ast.identExpr) =
    let val _ = trace([">> qualifiedIdentifierPrime with next=",tokenname(hd(ts1))]) 
    in case ts1 of
        LEFTBRACKET :: ts => 
			let
				val (ts2,nd2) = brackets (ts1)
                val (ts3,nd3) = (ts2,Ast.QualifiedExpression({qual=nd1,expr=nd2}))

			in
				(ts3,nd3)
			end
      | tk :: ts =>
            let
                val (ts2,nd2) = reservedOrPropertyIdentifier(ts1)
				val qid = Ast.QualifiedIdentifier({qual=nd1, ident=nd2})
                val (ts3,nd3) = (ts2,qid)
            in
                (ts3,nd3)
            end
    end

(*
    NonAttributeQualifiedIdentifier    
        SimpleQualifiedIdentifier
        ExpressionQualifiedIdentifier
*)

and nonAttributeQualifiedIdentifier ts =
    let val _ = trace([">> nonAttributeQualifiedIdentifier with next=",tokenname(hd(ts))]) 
    in case ts of
        LEFTPAREN :: _ => expressionQualifiedIdentifier(ts)
      | _ => 
        	let
            	val (ts1,nd1) = simpleQualifiedIdentifier(ts)
	        in
    	        (trace(["<< nonAttributeQualifiedIdentifier with next=",tokenname(hd(ts1))]);(ts1,nd1))
        	end
    end

(*
    AttributeIdentifier    
        @  Brackets
        @  NonAttributeQualifiedIdentifier
*)

and attributeIdentifier ts =
    let val _ = trace([">> attributeIdentifier with next=",tokenname(hd(ts))]) 
    in case ts of
        AT :: LEFTBRACKET :: _ => 
			let
				val (ts1,nd1) = brackets(tl ts)
			in
				(ts1,Ast.AttributeIdentifier (Ast.Expression nd1))
			end
      | AT :: _ => 
			let
				val (ts1,nd1) = nonAttributeQualifiedIdentifier(tl ts)
			in
				(ts1,Ast.AttributeIdentifier nd1)
			end
      | _ => 
			raise ParseError
    end

(*

    QualifiedIdentifier    
        AttributeIdentifier
        NonAttributeQualifiedIdentifier

*)

and qualifiedIdentifier ts =
    let val _ = trace([">> qualifiedIdentifier with next=",tokenname(hd(ts))]) 
    in case ts of
        AT :: _ => attributeIdentifier(ts)
      | _ => nonAttributeQualifiedIdentifier(ts)
    end

(*
    SimpleTypeIdentifier    
        PackageIdentifier  .  Identifier
        NonAttributeQualifiedIdentifier
*)

and simpleTypeIdentifier ts =
    let val _ = trace([">> simpleTypeIdentifier with next=",tokenname(hd(ts))]) 
    in case ts of
        PACKAGEIDENTIFIER :: DOT :: ts1 => 
            let val (ts2,nd2) = identifier(ts1) 
				val nd' = Ast.QualifiedIdentifier(
					       {qual=Ast.LiteralExpr(Ast.LiteralNamespace(Ast.Namespace(Ast.PUBLIC,"p"))),
						    ident=nd2})
			in 
				(ts2,nd') 
			end
      | _ => nonAttributeQualifiedIdentifier(ts)
    end

(*
    TypeIdentifier    
        SimpleTypeIdentifier
        SimpleTypeIdentifier  .<  TypeExpressionList  >
*)

and typeIdentifier ts =
    let val _ = trace([">> typeIdentifier with next=",tokenname(hd(ts))]) 
        val (ts1,nd1) = simpleTypeIdentifier ts
    in case ts1 of
        LEFTDOTANGLE :: ts2 => 
            let
                val (ts3,nd3) = typeExpressionList ts2
            in case ts3 of
                RIGHTANGLE :: ts4 => (ts4,nd3)
              | _ => raise ParseError
            end
      | _ => (ts1, nd1)        
    end

(*
    ParenExpression    
        (  AssignmentExpressionallowLet, allowIn  )
*)

and parenExpression ts =
    let val _ = trace([">> parenExpression with next=",tokenname(hd(ts))]) 
    in case ts of
        LEFTPAREN :: ts1 => 
            let
                val (ts2,nd2:Ast.expr) = assignmentExpression (ts1,ALLOWLIST,ALLOWIN)
            in case ts2 of
                RIGHTPAREN :: ts3 => (ts3,nd2)
              | _ => raise ParseError
            end
      | _ => raise ParseError
    end

(*
    ParenListExpression    
        (  ListExpressionallowIn  )
*)

and parenListExpression ts =
    let val _ = trace([">> parenListExpression with next=",tokenname(hd(ts))]) 
    in case ts of
        LEFTPAREN :: ts1 => 
            let
                val (ts2,nd2) = listExpression (ts1,ALLOWIN)
            in case ts2 of
                RIGHTPAREN :: ts3 => (ts3,nd2)
              | _ => raise ParseError
            end
      | _ => raise ParseError
    end

(*
    FunctionExpression    
        function  FunctionCommon
        function  FunctionSignature ListExpression(beta)
        function  Identifier  FunctionCommon
        function  Identifier  FunctionCommon

    FunctionCommon    
        FunctionSignature
        FunctionSignature Block
*)

and functionExpression (ts,alpha,beta) =
    let val _ = trace([">> functionExpression with next=",tokenname(hd(ts))]) 
    in case ts of
        FUNCTION :: ts1 => 
			let
			in case ts1 of
				(LEFTDOTANGLE | LEFTPAREN) :: _ => 
					let
						val (ts3,nd3) = functionSignature ts1
					in case (ts3,alpha) of
						(LEFTBRACE :: _,_) => 
							let
								val (ts4,nd4) = block ts3
							in
								(ts4,Ast.FunExpr {ident=NONE,sign=nd3,body=nd4})
							end
					  | (_,ALLOWLIST) => 
							let
								val (ts4,nd4) = listExpression (ts3,beta)
							in
								(ts4,Ast.FunExpr{ident=NONE,sign=nd3,
									body=Ast.Block { directives=[],defns=[],stmts=[Ast.ReturnStmt nd4] }})

							end
					end
		      | _ => 
					let
						val (ts2,nd2) = identifier ts1
						val (ts3,nd3) = functionSignature ts2
val _ = log(["funexpr"])
					in case (ts3,alpha) of
						(LEFTBRACE :: _,_) => 
							let
								val (ts4,nd4) = block ts3
							in
								(ts4,Ast.FunExpr {ident=SOME nd2,sign=nd3,body=nd4})
							end
					  | (_,ALLOWLIST) => 
							let
								val (ts4,nd4) = listExpression (ts3,beta)
							in
								(ts4,Ast.FunExpr{ident=SOME nd2,sign=nd3,
									body=Ast.Block { directives=[],defns=[],stmts=[Ast.ReturnStmt nd4] }})

							end
					end
			end
      | _ => raise ParseError
    end

and functionCommon ts =
    let val _ = trace([">> functionCommon with next=",tokenname(hd(ts))]) 
        val (ts1,nd1) = functionSignature ts
    in case ts1 of
        LEFTBRACE :: _ => 
            let
                val (ts2,nd2) = block ts1
            in
                (ts2,Ast.FunExpr {ident=NONE,sign=nd1,body=nd2})
            end
      | _ => raise ParseError
    end

(*
    FunctionSignature
        .<  TypeParameterList  > (  Parameters  )  ResultType
        (  Parameters  )  ResultType

    re-factored:

    FunctionSignature
        .<  TypeParameterList  > FunctionSignaturePrime
        FunctionSignaturePrime

    FunctionSignaturePrime
        (  Parameters  )  ResultType
*)

and functionSignature ts =
    let val _ = trace([">> functionSignature with next=",tokenname(hd(ts))]) 
		fun functionSignature' (ts, nd1) =
            case ts of
                LEFTPAREN :: ts1 =>
                   let
                       val (ts2, nd2) = parameters ts1
                   in case ts2 of
                       RIGHTPAREN :: tsx =>
                           let
                               val (ts3,nd3) = resultType tsx
val _ = log(["functionSignature with next=",tokenname(hd ts3)])
                           in
                               (ts3,Ast.FunctionSignature {typeparams=nd1,params=nd2,resulttype=nd3})
                           end
                     | _ => raise ParseError
                   end
              | _ => raise ParseError
    in case ts of
        LEFTDOTANGLE :: ts1 => 
            let
                val (ts2,nd2) = typeParameterList ts1
            in
                let
                in case ts2 of
                    GREATERTHAN :: ts3 => functionSignature' (ts3, nd2)
                  | _ => raise ParseError
                end
            end
      | _ => functionSignature' (ts, [])
    end

(*
    TypeParametersList    
        Identifier
        Identifier  ,  TypeParameterList

    left factored:

    TypeParameterList
        Identifier TypeParameterListPrime

    TypeParameterListPrime
        �empty�
        ,  Identififier  TypeParameterListPrime
*)

and typeParameterList ts =
    let val _ = trace([">> typeParameterList with next=",tokenname(hd(ts))]) 
		fun typeParameterList' (ts, lst) =
	    	let
    		in case ts of
        		COMMA :: ts1 =>
           			let
               			val (ts2,nd2) = identifier(ts1)
               			val (ts3,nd3) = typeParameterList' (ts2,Ast.LiteralString(nd2)::lst)
           			in
             			(ts3,nd3)
           			end
			  | _ => (ts,lst)
    end
        val (ts1,nd1) = identifier ts
        val (ts2,nd2) = typeParameterList' (ts1,Ast.LiteralString(nd1)::nil)
    in
        (ts2,nd2)
    end

(*
    Parameters    
        �empty�
        NonemptyParameters(ALLOWLIST)

    NonemptyParameters(alpha)    
        ParameterInit(alpha)
        ParameterInit(NOLIST)  ,  NonemptyParameters(alpha)
        RestParameter

    type formal =
         { name: ident,
           ty: tyExpr option,
           init: expr option,
		   tag: varDefnTag,
           isRest: bool }
*)

and parameters ts =
    let val _ = trace([">> parameters with next=",tokenname(hd(ts))]) 
		fun nonemptyParameters (ts,alpha) = 
			let
			in case ts of
				TRIPLEDOT :: _ => 
					let
						val (ts1,nd1) = restParameter (ts)
					in case ts1 of
						RIGHTPAREN :: _ => (ts1,nd1::[])
					  | _ => raise ParseError
					end					
			  | _ => 
					let
						val (ts1,nd1) = parameterInit (ts,NOLIST)
					in case ts1 of
						RIGHTPAREN :: _ => (ts1,nd1::[])
					  | COMMA :: ts2 =>
							let
								val (ts3,nd3) = nonemptyParameters (ts2,alpha)
							in
								(ts3,nd1::nd3)
							end
					  | _ => raise ParseError
					end
			end
	in case ts of 
		RIGHTPAREN :: ts1 => (ts,[])
	  | _ => nonemptyParameters(ts,ALLOWLIST)
	end

(*
    ParameterInit(alpha)
        Parameter
        Parameter  =  NonAssignmentExpression(alpha,ALLOWIN)

        formal = { name: ident,
           ty: tyExpr option,
           init: expr option,
		   tag: varDefnTag,
           isRest: bool }
*)

and parameterInit (ts, alpha) = 
    let val _ = trace([">> parameterInit with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = parameter (ts,alpha)
	in case ts1 of
		ASSIGN :: ts2 => 
			let
				val (ts3,nd3) = nonAssignmentExpression (ts2,alpha,ALLOWIN)
			in 
				raise ParseError (*(ts3,{name=name,ty=ty,tag=tag,init=SOME nd3,isRest=false})*)
			end
	  | _ => (ts1,nd1)
	end

(*
    Parameter    
        ParameterAttributes TypedIdentifier(ALLOWIN)
        ParameterAttributes TypedPattern

    ParameterAttributes    
        �empty�
        const
*)

and parameter (ts, alpha) : token list * Ast.formal =
    let val _ = trace([">> parameter with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = parameterAttributes (ts)
	in case ts1 of
		(LEFTBRACKET | LEFTPAREN) :: _ => 
			let
				val (ts2,{ptrn,ty}) = typedPattern (ts1)
			in
				(ts2,{name=Ast.Pattern(ptrn),ty=ty,tag=nd1,isRest=false,init=NONE})
			end
	  | _ => 
			let
				val (ts2:token list,{name,ty}) = typedIdentifier (ts1)
			in
				(ts2,{name=Ast.Ident(name),ty=ty,tag=nd1,isRest=false,init=NONE})
			end			
	end

and parameterAttributes (ts) = 
    let val _ = trace([">> parameterAttributes with next=",tokenname(hd(ts))]) 
	in case ts of 
		CONST :: ts1 => (ts1,Ast.CONST)
	  | ts1 => (ts1,Ast.VAR)
	end

(*
    RestParameter    
        ...
        ...  ParameterAttributes TypedIdentifier
        ...  ParameterAttributes TypedPattern
*)

and restParameter (ts:token list) = 
    let val _ = trace([">> restParameter with next=",tokenname(hd(ts))]) 
		val (DOTDOTDOT :: ts1) = ts
	in case ts1 of
		RIGHTPAREN :: _ => (ts1,{name=Ast.Ident(""),ty=NONE,tag=Ast.VAR,isRest=true,init=NONE}) 
	  | _ => 
			let
				val (ts2:token list,{name,ty,tag,...}) = parameter (ts1,ALLOWLIST)
			in
				(ts2,{name=name,ty=ty,tag=tag,isRest=true,init=NONE})
			end
	end

(*
	TypedIdentifier(beta)    
    	Identifier
	    Identifier  :  TypeExpressionx
*)

and typedIdentifier (ts) =
    let val _ = trace([">> typedIdentifier with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = identifier ts
	in case ts1 of
		COLON :: ts2 => 
			let
				val (ts3,nd3) = typeExpression (ts2)
val _ = log(["typedIdentifier with next=",tokenname(hd ts2)])
			in
				(ts3, {name=nd1,ty=SOME nd3})
			end
		
	  | ts3 => 
			let
			in
				(ts3, {name=nd1,ty=NONE})
			end
		
	end

(*
	TypedPattern    
    	Pattern
	    Pattern  :  TypeExpression
*)

and typedPattern ts =
	let
		val (ts1,nd1) = pattern ts
	in case ts of 
		COLON :: _ =>
			let
				val (ts2,nd2) = typeExpression (tl ts)
val _ = log(["typedPattern with next=",tokenname(hd ts2)])
			in
				(ts2,{ptrn=nd1,ty=SOME nd2})
			end
	end
    
(*
    ResultType
        �empty�
        :  void
        :  TypeExpression
*)

and resultType ts = 
    let val _ = trace([">> resultType with next=",tokenname(hd(ts))]) 
    in case ts of
        COLON :: VOID :: ts1 => (ts1,Ast.SpecialType(Ast.NOTYPE))
      | COLON :: _ => 
			let
				val (ts1,nd1) = typeExpression (tl ts)
			in
				log(["<< resultType with next=",tokenname(hd ts1)]);
				(ts1,nd1)
			end
	  | ts1 => (ts1,Ast.SpecialType(Ast.UNDEFINED))
    end

(*
    ObjectLiteral    
        {  FieldList  }
        {  FieldList  }  :  RecordType
*)

and objectLiteral ts = 
    let val _ = trace([">> objectLiteral with next=",tokenname(hd(ts))]) 
	in case ts of
		LEFTBRACE :: ts1 => 
			let
				val (ts2,nd2) = fieldList ts1
			in case ts2 of
				RIGHTBRACE :: COLON :: ts3 => raise ParseError (* todo: record type anno *)
			  | RIGHTBRACE :: ts3 => (trace(["<< objectLiteral with next=",tokenname(hd(ts3))]);(ts3,Ast.LiteralObject nd2))
			  | _ => raise ParseError
			end
	  | _ => raise ParseError
	end

(*
    FieldList    
        �empty�
        NonemptyFieldList(allowLet)

    NonemptyFieldList(alpha)
        LiteralField(alpha)
        LiteralField(noLet)  ,  NonemptyFieldList(alpha)
*)

and fieldList ts =
    let val _ = trace([">> fieldList with next=",tokenname(hd(ts))]) 
		fun nonemptyFieldList (ts,alpha) =
			let
				val (ts1,nd1) = literalField(ts,alpha)
			in case ts1 of
				COMMA :: ts2 => 
					let
						val (ts3,nd3) = nonemptyFieldList (ts2,alpha)
					in
						(ts3,nd1::nd3)
					end
			  | _ => (ts1,nd1::[])
			end
	in case ts of
		RIGHTBRACE :: ts1 => (ts1,[])
	  | _ => nonemptyFieldList (ts,ALLOWLIST)
	end

(*
    LiteralField (alpha)    
        FieldName  :  AssignmentExpression(alpha, ALLOWIN)
		get  Identifier  FunctionCommon
		set  Identifier  FunctionCommon

    FieldName    
        NonAttributeQualifiedIdentifier
        StringLiteral
        NumberLiteral
        ReservedIdentifier
*)

and literalField (ts, alpha) =
    let val _ = trace([">> literalField with next=",tokenname(hd(ts))]) 
	in case ts of
		GET :: _ =>
			let
				val (ts1,nd1) = fieldName (tl ts)
				val (ts2,nd2) = functionCommon (ts1)
			in
				(ts2,{name=nd1,init=nd2})
			end
	  | SET :: _ =>
			let
				val (ts1,nd1) = fieldName (tl ts)
				val (ts2,nd2) = functionCommon (ts1)
			in
				(ts2,{name=nd1,init=nd2})
			end
	  | _ => 
			let
				val (ts1,nd1) = fieldName ts
			in case ts1 of
				COLON :: _ =>
					let
						val (ts2,nd2) = assignmentExpression (tl ts1,alpha,ALLOWIN)
					in
						(ts2,{name=nd1,init=nd2})
					end
			  | _ => raise ParseError
			end
	end

and fieldName ts =
    let val _ = trace([">> fieldName with next=",tokenname(hd(ts))]) 
	in case ts of
		STRINGLITERAL s :: ts1 => (ts1,Ast.LiteralExpr(Ast.LiteralString(s)))
	  | NUMBERLITERAL n :: ts1 => (ts1,Ast.LiteralExpr(Ast.LiteralNumber(n)))
	  | _ => 
			let
				val (ts1,nd1) = identifier ts (* nonAttributeQualifiedIdentifier (ts) *)
			in
				(ts1,Ast.LiteralExpr(Ast.LiteralString(nd1)))
			end
	end

(*
    ArrayLiteral    
        [  ElementList(ALLOWLIST)  ]
        [  ElementList(ALLOWLIST)  ]  :  ArrayType
*)

and arrayLiteral ts =
    let val _ = trace([">> arrayLiteral with next=",tokenname(hd(ts))]) 
	in case ts of
		LEFTBRACKET :: ts1 => 
			let
				val (ts2,nd2) = elementList (ts1,ALLOWLIST)
			in case ts2 of
				RIGHTBRACKET :: COLON :: ts3 => raise ParseError (* todo: array type anno *)
			  | RIGHTBRACKET :: ts3 => (ts3,Ast.LiteralExpr(Ast.LiteralArray nd2))
			  | _ => raise ParseError
			end
	  | _ => raise ParseError
	end

(*
    ElementList(alpha)
        �empty�
        LiteralElement(alpha)
        ,  ElementList(alpha)
        LiteralElement(NOLIST)  ,  ElementList(alpha)

    LiteralElement(alpha)
        AssignmentExpression(alpha, ALLOWIN)
*)

and elementList (ts,alpha) =
    let val _ = trace([">> elementList with next=",tokenname(hd(ts))]) 
	in case ts of
		RIGHTBRACKET :: _ => (ts,[])
	  | COMMA :: _ => 
			let
				val (ts1,nd1) = elementList (tl ts,alpha)
			in
				(ts1,Ast.LiteralExpr(Ast.LiteralUndefined) :: nd1)
			end
	  | _ =>
			let
				val (ts1,nd1) = assignmentExpression (ts,alpha,ALLOWIN)
			in case ts1 of
				COMMA :: _ =>
					let
						val (ts2,nd2) = elementList (tl ts1,alpha)
					in
						(ts2,nd1::nd2)
					end
			  | _ => (ts1,nd1::[])
			end
	end

(*
    XMLInitialiser    
        XMLMarkup
        XMLElement
        <  >  XMLElementContent  </  >

    XMLElementContent    
        XMLMarkup  XMLElementContentopt
        XMLText  XMLElementContentopt
        XMLElement  XMLElementContentopt
        {  ListExpressionallowIn  }  XMLElementContentopt
    
    XMLElement    
        <  XMLTagContent  XMLWhitespaceopt  />
        <  XMLTagContent  XMLWhitespaceopt  >  XMLElementContent
                  </  XMLTagName  XMLWhitespaceopt  >
    
    XMLTagContent    
        XMLTagName  XMLAttributes
    
    XMLTagName    
        {  ListExpressionallowIn  }
        XMLName
    
    XMLAttributes    
        XMLWhitespace  {  ListExpressionallowIn  }
        XMLAttribute  XMLAttributes
        �empty�
    
    XMLAttribute    
        XMLWhitespace  XMLName  XMLWhitespaceopt  =  XMLWhitespaceopt  {  ListExpressionallowIn  }
        XMLWhitespace  XMLName  XMLWhitespaceopt  =  XMLWhitespaceopt  XMLAttributeValue
    
    XMLElementContent    
        {  ListExpressionallowIn  }  XMLElementContent
        XMLMarkup  XMLElementContent
        XMLText  XMLElementContent
        XMLElement  XMLElementContent
        �empty�
*)

(*
    CastExpression    
        cast  TypeExpression  ParenListExpression
*)

and castExpression ts =
    let
    in case ts of
        CAST :: ts1 =>
            let
                val (ts2,nd2) = typeExpression(ts1)
                val (ts3,nd3) = parenListExpression(ts2)
            in
                (ts3,Ast.BinaryTypeExpr(Ast.CAST,nd3,nd2))
            end
      | _ => raise ParseError
    end

(*
	PrimaryExpression    
    	null
	    true
    	false
	    NumberLiteral
    	StringLiteral
	    this
    	RegularExpression
	    TypeIdentifier
    	AttributeIdentifier
	    XMLInitialiser
    	ParenListExpression
	    ArrayLiteral
    	ObjectLiteral
	    FunctionExpression
    	CastExpression
*)

and regexpLiteral (ts, regex) =
    let val _ = trace(["regexp=",regex])
    in case ts of 
        DIV :: tr => 
            let
            in
                (tr,Ast.LiteralExpr(Ast.LiteralRegExp{pattern=regex,global=false,multiline=false,caseInsensitive=false}))
            end
      | tk :: tr  => regexpLiteral (tr,tokenname(tk)^regex)
    end

and primaryExpression ts =
    let val _ = trace([">> primaryExpression with next=",tokenname(hd ts)])
    in case ts of
        NULL :: ts1 => (ts1, Ast.LiteralExpr(Ast.LiteralNull))
      | TRUE :: ts1 => (ts1, Ast.LiteralExpr(Ast.LiteralBoolean true))
      | FALSE :: ts1 => (ts1, Ast.LiteralExpr(Ast.LiteralBoolean false))
      | NUMBERLITERAL n :: ts1 => (ts1, Ast.LiteralExpr(Ast.LiteralNumber n))
      | STRINGLITERAL s :: ts1 => (ts1, Ast.LiteralExpr(Ast.LiteralString s))
      | THIS :: ts1 => (ts1, Ast.NullaryExpr Ast.THIS)
      | AT :: _ => 
			let
				val (ts1,nd1) = attributeIdentifier ts
			in
				(ts1,Ast.Ref {base=NONE,ident=nd1})
			end
      | LEFTPAREN :: _ => parenListExpression ts
      | LEFTBRACKET :: _ => arrayLiteral ts
      | LEFTBRACE :: _ => let val (ts1,nd1) = objectLiteral ts in (ts1,Ast.LiteralExpr nd1) end
      | FUNCTION :: _ => functionExpression (ts,ALLOWLIST,ALLOWIN)  (* fixme: need to propagate alpha and beta *)
      | CAST :: _ => castExpression ts
      | DIV :: ts1 => regexpLiteral (ts1,"")

(* todo
      | REGEXP r :: ts1 => (ts1, Ast.RegExp(r))
      | (XMLMARKUP | LESSTHAN ) :: _ => xmlInitializer ts
*)
      | EOL :: ts1 => primaryExpression ts1
      | _ => 
			let
				val (ts1,nd1) = typeIdentifier ts
			in
				(ts1,Ast.Ref {base=NONE,ident=nd1})
			end
    end

(*

SuperExpression    
    super
    super  ParenExpression

*)

and superExpression ts =
    let val _ = trace([">> superExpression with next=",tokenname(hd(ts))]) 
        val (SUPER :: ts1) = ts
    in case ts1 of
        LEFTPAREN :: _ => 
            let
                val (ts2,nd2) = parenExpression(ts1)
                val (ts3,nd3) = (ts2,Ast.SuperExpr(SOME(nd2)))
            in
                (ts3,nd3)
            end
        | _ => (ts1,Ast.SuperExpr(NONE))
    end

(*
    MemberExpression    
        PrimaryExpression
        new  MemberExpression  Arguments
        SuperExpression  PropertyOperator
        MemberExpression  PropertyOperator

    Refactored:

    MemberExpression :    
        PrimaryExpression MemberExpressionPrime
        new MemberExpression Arguments MemberExpressionPrime
        SuperExpression  PropertyOperator  MemberExpressionPrime
    
    MemberExpressionPrime :    
        PropertyOperator MemberExpressionPrime
        �empty�
*)

and memberExpression ts =
    let val _ = trace([">> memberExpression with next=",tokenname(hd(ts))]) 
    in case ts of
        NEW :: ts' =>
            let
                val (ts1,nd1) = memberExpression(ts')
                val (ts2,nd2) = arguments(ts1)
                val (ts3,nd3) = memberExpressionPrime(ts2,Ast.CallExpr {func=nd1,actuals=nd2})
            in
                (ts3,nd3)
            end
      | SUPER :: _ =>
            let
                val (ts2,nd2) = superExpression(ts)
                val (ts3,nd3) = propertyOperator(ts2,nd2)
                val (ts4,nd4) = memberExpressionPrime(ts3,nd3)
               in
                (ts4,nd4)
            end
      | _ =>
            let
                val (ts3,nd3) = primaryExpression(ts)
                val (ts4,nd4) = memberExpressionPrime(ts3,nd3)
               in
                (trace(["<< memberExpression with next=",tokenname(hd ts4)]);(ts4,nd4))
            end
    end

and memberExpressionPrime (ts,nd) =
    let val _ = trace([">> memberExpressionPrime with next=",tokenname(hd(ts))])
    in case ts of
        (LEFTBRACKET :: _ | DOT :: _) =>
            let
                val (ts2,nd2) = propertyOperator(ts,nd)
            in
                memberExpressionPrime(ts2, nd2)
            end
      | _ => (ts,nd)
    end

(*
    CallExpression    
        MemberExpression  Arguments
        CallExpression  Arguments
        CallExpression  PropertyOperator

    refactored:

    CallExpression :    
        MemberExpression Arguments CallExpressionPrime
    
    CallExpressionPrime :    
        Arguments CallExpressionPrime
        PropertyOperator CallExpressionPrime
        �empty�
*)

and callExpression ts =
    let val _ = trace([">> callExpression with next=",tokenname(hd(ts))]) 
        val (ts1,nd1) = memberExpression(ts)
        val (ts2,nd2) = arguments(ts1)
    in 
        callExpressionPrime(ts2,Ast.CallExpr({func=nd1,actuals=nd2}))
    end

and callExpressionPrime (ts,nd1) =
    let val _ = trace([">> callExpressionPrime with next=",tokenname(hd(ts))])
    in case ts of
        (LEFTBRACKET :: ts1 | DOT :: ts1) =>
            let
                val (ts2,nd2) = propertyOperator(ts1,nd1)
            in
                memberExpressionPrime(ts2, nd2)
            end
      | LEFTPAREN :: _ => 
            let
                val (ts2,nd2) = arguments(ts)
            in
                memberExpressionPrime(ts2,Ast.CallExpr({func=nd1,actuals=nd2}))
            end
      | ts1 => (ts1,nd1)
    end

(*
    Arguments    
        (  )
        (  ArgumentList(ALLOWLIST)  )
*)

and arguments (ts) : (token list * Ast.expr list)  =
    let val _ = trace([">> arguments with next=",tokenname(hd(ts))]) 
	in case ts of
        LEFTPAREN :: RIGHTPAREN :: ts1 => (ts1,[]) 
      | LEFTPAREN :: ts1 => 
			let
		        val (ts2,nd2) = argumentList(ts1,ALLOWLIST)
			in case ts2 of
				RIGHTPAREN :: ts3 => (ts3,nd2)
			  | _ => raise ParseError
			end
	  | _ => raise ParseError
    end

(*
    ArgumentList(alpha)    
        AssignmentExpression(alpha, ALLOWIN)
        ArgumentList(NOLIST)  ,  AssignmentExpression(alpha, ALLOWIN)

    refactored:

    ArgumentList(alpha)
        AssignmentExpression(alpha,ALLOWIN) ArgumentListPrime(ALLOWLIST)

    ArgumentListPrime(alpha)
        �empty�
        [NOLIST] , AssignmentExpression(alpha,ALLOWIN) ArgumentListPrime(ALLOWLIST)
*)

and argumentList (ts, alpha) : (token list * Ast.expr list)  =
    let val _ = trace([">> argumentList with next=",tokenname(hd(ts))])
        val (ts1,nd1) = assignmentExpression(ts,alpha,ALLOWIN)
        val (ts2,nd2) = argumentListPrime(ts1,ALLOWLIST,nd1)
    in
        (ts2,nd2)
    end

and argumentListPrime (ts, alpha, nd) : (token list * Ast.expr list) =
    let val _ = trace([">> argumentList with next=",tokenname(hd(ts))])
    in case (ts,nd) of
        (COMMA :: _, Ast.LetExpr _) => raise ParseError
      | (COMMA :: ts1, _) => 
            let
                val (ts2,nd2) = assignmentExpression(ts1,alpha,ALLOWIN)
                val (ts3,nd3) = argumentListPrime(ts2,ALLOWLIST,nd2)
            in
                (ts3,nd::nd3)
            end
      | _ => (ts,[nd])
    end

(*

PropertyOperator    
    .. QualifiedIdentifier
    .  ReservedIdentifier
    .  QualifiedIdentifier
    .  ParenListExpression
    .  ParenListExpression  ::  PropertyIdentifier
    .  ParenListExpression  ::  ReservedIdentifier
    .  ParenListExpression  ::  Brackets
    Brackets
    
*)

and propertyOperator (ts, nd) =
    let val _ = trace([">> propertyOperator with next=",tokenname(hd(ts))]) 
    in case ts of
        DOT :: ts1 =>
            let
            in case ts1 of
                LEFTPAREN :: _ =>
                    let
                        val (ts2,nd2) = parenListExpression(ts1)
					in case ts2 of
						DOUBLECOLON:: BRACKET :: _ => 
               			    let
                                val (ts4,nd4) = brackets(tl ts2)
   			                in
               			        (ts4,Ast.Ref {base=SOME nd,ident=Ast.Expression(nd4)})
                            end
					  | DOUBLECOLON :: ts3 => 
                            let
                                val (ts4,nd4) = reservedOrPropertyIdentifier(ts3)
                            in
                                (ts4,Ast.Ref({base=SOME nd,ident=Ast.Identifier(nd4)}))
                            end
					  | _ => raise ParseError
                    end
              | _ => 
                    let
                        val (ts4,nd4) = reservedOrPropertyIdentifier(ts1)
                    in
                        (ts4,Ast.Ref({base=SOME nd,ident=Ast.Identifier(nd4)}))
                    end
            end
      | LEFTBRACKET :: _ => 
            let
                val (ts4,nd4) = brackets(ts)
            in
                (ts4,Ast.Property({obj=SOME nd,field=nd4,indirect=false}))
            end
      | _ => raise ParseError
    end

(*

Brackets    
    [  ]
    [  ListExpression(allowIn)  ]
    [  ListExpression(allowIn)  :  ListExpression(allowIn)  ]
    
*)

and brackets (ts) =
    let val _ = trace([">> brackets with next=",tokenname(hd(ts))]) 
    in case ts of
		LEFTBRACKET :: ts' =>
			let
				val (ts1,nd1) = listExpression (ts',ALLOWIN)
			in case ts1 of
				COLON :: ts'' => 
					let
						val (ts2,nd2) = listExpression (ts'',ALLOWIN)
					in case ts2 of
						RIGHTBRACKET :: ts'' => (ts'',nd1) 
							(* fixme: need an ast for slice *)
					  | _ => raise ParseError
					end
			  | RIGHTBRACKET :: ts'' => (ts'',nd1) 
			  | _ => raise ParseError
			end
	end

(*

NewExpression    
    MemberExpression
    new  NewExpression
    
*)

and newExpression ts =
    let val _ = trace([">> newExpression with next=",tokenname(hd(ts))]) 
    in case ts of
        NEW :: ts1 =>
            let
                val (ts2,nd2) = newExpression(ts1)
            in
                (ts2,Ast.NewExpr({obj=nd2,actuals=[]}))
            end
      | _ => memberExpression(ts)
    end

(*
    LeftHandSideExpression    
        NewExpression
        CallExpression
    
    refactored:

    LeftHandSideExpression    
        new NewExpression
        MemberExpression Arguments CallExpressionPrime
        MemberExpression
*)

and leftHandSideExpression ts =
    let val _ = trace([">> leftHandSideExpression with next=",tokenname(hd(ts))]) 
    in case ts of
        NEW :: ts1 =>
            let
                val (ts2,nd2) = newExpression(ts1)
            in
                (ts2,Ast.NewExpr({obj=nd2,actuals=[]}))
            end
      | _ =>
            let
                val (ts2,nd2) = memberExpression(ts)
            in case ts2 of
                LEFTPAREN :: _ =>
                    let
                        val (ts3,nd3) = arguments(ts2)
                        val (ts4,nd4) = callExpressionPrime(ts3,Ast.CallExpr {func=nd2,actuals=nd3})
                    in
						(trace(["<< leftHandSideExpression with next=",tokenname(hd(ts4))]);(ts4,nd4))
                    end
              | _ => (trace(["<< leftHandSideExpression with next=",tokenname(hd(ts))]);(ts2,nd2))
            end
    end

(*

PostfixExpression    
    LeftHandSideExpression
    LeftHandSideExpression  [no line break]  ++
    LeftHandSideExpression  [no line break]  --
    
*)

and postfixExpression ts =
    let val _ = trace([">> postfixExpression with next=",tokenname(hd(ts))]) 
        val (ts1,nd1) = leftHandSideExpression(ts)
    in case ts1 of
		PLUSPLUS :: ts2 => (ts2,Ast.UnaryExpr(Ast.POST_INCREMENT,nd1))
	  | MINUSMINUS :: ts2 => (ts2,Ast.UnaryExpr(Ast.POST_DECREMENT,nd1))
	  | _ => (trace(["<< postfixExpression"]);(ts1,nd1))
    end

(*

UnaryExpression    
    PostfixExpression
    delete  PostfixExpression
    void  UnaryExpression
    typeof  UnaryExpression
    ++   PostfixExpression
    --  PostfixExpression
    +  UnaryExpression
    -  UnaryExpression
    ~  UnaryExpression
    !  UnaryExpression
    type TypeExpression
    
*)

and unaryExpression ts =
    let val _ = trace([">> unaryExpression with next=",tokenname(hd(ts))]) 
    in case ts of
		DELETE :: ts1 => let val (ts2,nd2) = postfixExpression ts1 in (ts2,Ast.UnaryExpr(Ast.DELETE,nd2)) end
	  | VOID :: ts1 => let val (ts2,nd2) = unaryExpression ts1 in (ts2,Ast.UnaryExpr(Ast.VOID,nd2)) end
	  | TYPEOF :: ts1 => let val (ts2,nd2) = unaryExpression ts1 in (ts2,Ast.UnaryExpr(Ast.TYPEOF,nd2)) end
	  | PLUSPLUS :: ts1 => let val (ts2,nd2) = postfixExpression ts1 in (ts2,Ast.UnaryExpr(Ast.PRE_INCREMENT,nd2)) end
	  | MINUSMINUS :: ts1 => let val (ts2,nd2) = postfixExpression ts1 in (ts2,Ast.UnaryExpr(Ast.PRE_DECREMENT,nd2)) end
	  | PLUS :: ts1 => let val (ts2,nd2) = unaryExpression ts1 in (ts2,Ast.UnaryExpr(Ast.UNARY_PLUS,nd2)) end
	  | BITWISENOT :: ts1 => let val (ts2,nd2) = unaryExpression ts1 in (ts2,Ast.UnaryExpr(Ast.BITWISE_NOT,nd2)) end
	  | NOT :: ts1 => let val (ts2,nd2) = unaryExpression ts1 in (ts2,Ast.UnaryExpr(Ast.LOGICAL_NOT,nd2)) end
	  | TYPE :: ts1 => let val (ts2,nd2) = typeExpression ts1 in (ts2,Ast.TypeExpr(nd2)) end
	  | _ => postfixExpression ts
    end
    
(*

MultiplicativeExpression    
    UnaryExpression
    MultiplicativeExpression  *  UnaryExpression
    MultiplicativeExpression  /  UnaryExpression
    MultiplicativeExpression  %  UnaryExpression

right recursive:

MultiplicativeExpression	
	UnaryExpression MultiplicativeExpressionPrime
	
MultiplicativeExpression'	
	*  UnaryExpression MultiplicativeExpressionPrime
	/  UnaryExpression MultiplicativeExpressionPrime
	%  UnaryExpression MultiplicativeExpressionPrime
	empty
    
*)

and multiplicativeExpression ts =
    let val _ = trace([">> multiplicativeExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = unaryExpression ts
		fun multiplicativeExpression' (ts1, nd1) =
			case ts1 of
				MULT :: ts2 => let val (ts3,nd3) = unaryExpression ts2 in multiplicativeExpression' (ts3,Ast.BinaryExpr(Ast.TIMES,nd1,nd3)) end
			  | DIV :: LEXBREAK_DIV x :: _ => 
					let 
						val ts2 = (#lex_initial x)()
						val (ts3,nd3) = unaryExpression ts2 
					in 
						multiplicativeExpression' (ts3,Ast.BinaryExpr(Ast.DIVIDE,nd1,nd3)) 
					end

		(* fixme: modify the lexer so that it puts LEXBREAK_SLASH 
		  			(as in the '/' character rather than the DIV token) 
                  	in the current token stream and DIV into the next one 
					so that the previous case would be coded like this:

			  | LEXBREAK_SLASH x :: _ =>
					let	in case (#lex_initial x)() of
						DIV :: ts2 => let val (ts3,nd3) = unaryExpression ts2 in multiplicativeExpression' (ts3,Ast.BinaryExpr(Ast.DIVID,nd1,nd3)) end
						_ => raise ParseError
		*)

			  | MODULUS :: ts2 => let val (ts3,nd3) = unaryExpression ts2 in multiplicativeExpression' (ts3,Ast.BinaryExpr(Ast.REMAINDER,nd1,nd3)) end
			  | _ => (trace(["<< multiplicative"]);(ts1,nd1))
    in
        multiplicativeExpression' (ts1,nd1)
    end

(*

AdditiveExpression    
    MultiplicativeExpression
    AdditiveExpression  +  MultiplicativeExpression
    AdditiveExpression  -  MultiplicativeExpression

right recursive: (see pattern of MultiplicativeExpression)

*)

and additiveExpression ts =
    let val _ = trace([">> additiveExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = multiplicativeExpression ts
		fun additiveExpression' (ts1, nd1) =
			case ts1 of
				PLUS :: ts2 => let val (ts3,nd3) = multiplicativeExpression ts2 in additiveExpression' (ts3,Ast.BinaryExpr(Ast.PLUS,nd1,nd3)) end
			  | MINUS :: ts2 => let val (ts3,nd3) = multiplicativeExpression ts2 in additiveExpression' (ts3,Ast.BinaryExpr(Ast.MINUS,nd1,nd3)) end
			  | _ => (trace(["<< additiveExpression"]);(ts1,nd1))
    in
        additiveExpression' (ts1,nd1)
    end

(*

	ShiftExpression    
	    AdditiveExpression
	    ShiftExpression  <<  AdditiveExpression
	    ShiftExpression  >>  AdditiveExpression
    	ShiftExpression  >>>  AdditiveExpression
    
	right recursive: (see pattern of MultiplicativeExpression)

*)

and shiftExpression ts =
    let val _ = trace([">> shiftExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = additiveExpression ts
		fun shiftExpression' (ts1, nd1) =
			case ts1 of
				LEFTSHIFT :: ts2 => let val (ts3,nd3) = additiveExpression ts2 in shiftExpression' (ts3,Ast.BinaryExpr(Ast.LEFT_SHIFT,nd1,nd3)) end
			  | RIGHTSHIFT :: ts2 => let val (ts3,nd3) = additiveExpression ts2 in shiftExpression' (ts3,Ast.BinaryExpr(Ast.RIGHT_SHIFT,nd1,nd3)) end
			  | UNSIGNEDRIGHTSHIFT :: ts2 => let val (ts3,nd3) = additiveExpression ts2 in shiftExpression' (ts3,Ast.BinaryExpr(Ast.RIGHT_SHIFT_UNSIGNED,nd1,nd3)) end
			  | _ => (trace(["<< shiftExpression"]);(ts1,nd1))
    in
        shiftExpression' (ts1,nd1)
    end

(*
	RelationalExpression(ALLOWIN)
    	ShiftExpression
	    RelationalExpressionallowIn  <  ShiftExpression
    	RelationalExpressionallowIn  >  ShiftExpression
	    RelationalExpressionallowIn  <=  ShiftExpression
    	RelationalExpressionallowIn  >=  ShiftExpression
	    RelationalExpressionallowIn  in  ShiftExpression
    	RelationalExpressionallowIn  instanceof  ShiftExpression
	    RelationalExpressionallowIn  is  TypeExpression
	    RelationalExpressionallowIn  to  TypeExpression

	RelationalExpression(NOIN)
    	ShiftExpression
	    RelationalExpressionallowIn  <  ShiftExpression
    	RelationalExpressionallowIn  >  ShiftExpression
	    RelationalExpressionallowIn  <=  ShiftExpression
    	RelationalExpressionallowIn  >=  ShiftExpression
    	RelationalExpressionallowIn  instanceof  ShiftExpression
	    RelationalExpressionallowIn  is  TypeExpression
	    RelationalExpressionallowIn  to  TypeExpression

	right recursive: (see pattern of MultiplicativeExpression)

*)

and relationalExpression (ts, beta)=
    let val _ = trace([">> relationalExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = shiftExpression ts
		fun relationalExpression' (ts1,nd1,beta) =
			case (ts1,beta) of
				(LESSTHAN :: ts2,_) => let val (ts3,nd3) = shiftExpression ts2 in relationalExpression' (ts3,Ast.BinaryExpr(Ast.LESS,nd1,nd3),ALLOWIN) end
			  | (GREATERTHAN :: ts2,_) => let val (ts3,nd3) = shiftExpression ts2 in relationalExpression' (ts3,Ast.BinaryExpr(Ast.GREATER,nd1,nd3),ALLOWIN) end
			  | (LESSTHANOREQUALS :: ts2, _) => let val (ts3,nd3) = shiftExpression ts2 in relationalExpression' (ts3,Ast.BinaryExpr(Ast.LESS_OR_EQUAL,nd1,nd3),ALLOWIN) end
			  | (GREATERTHANOREQUALS :: ts2, _) => let val (ts3,nd3) = shiftExpression ts2 in relationalExpression' (ts3,Ast.BinaryExpr(Ast.GREATER_OR_EQUAL,nd1,nd3),ALLOWIN) end
			  | (IN :: ts2, ALLOWIN) => let val (ts3,nd3) = shiftExpression ts2 in relationalExpression' (ts3,Ast.BinaryExpr(Ast.IN,nd1,nd3),ALLOWIN) end
			  | (INSTANCEOF :: ts2, _) => let val (ts3,nd3) = shiftExpression ts2 in relationalExpression' (ts3,Ast.BinaryExpr(Ast.INSTANCEOF,nd1,nd3),ALLOWIN) end
			  | (IS :: ts2, _) => let val (ts3,nd3) = typeExpression ts2 in relationalExpression' (ts3,Ast.BinaryTypeExpr(Ast.IS,nd1,nd3),ALLOWIN) end
			  | (TO :: ts2, _) => let val (ts3,nd3) = typeExpression ts2 in relationalExpression' (ts3,Ast.BinaryTypeExpr(Ast.TO,nd1,nd3),ALLOWIN) end
			  | (_,_) => (trace(["<< relationalExpression"]);(ts1,nd1))
    in
        relationalExpression' (ts1,nd1,beta)
    end

(*
	EqualityExpression(beta)
    	RelationalExpression(beta)
	    EqualityExpression(beta)  ==  RelationalExpression(beta)
	    EqualityExpression(beta)  !=  RelationalExpression(beta)
	    EqualityExpression(beta)  ===  RelationalExpression(beta)
	    EqualityExpression(beta)  !==  RelationalExpression(beta)

	right recursive: (see pattern of MultiplicativeExpression)

*)

and equalityExpression (ts, beta)=
    let val _ = trace([">> equalityExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = relationalExpression (ts,beta)
		fun equalityExpression' (ts1,nd1) =
			case ts1 of
				EQUALS :: ts2 => let val (ts3,nd3) = relationalExpression (ts2,beta) in equalityExpression' (ts3,Ast.BinaryExpr(Ast.EQUALS,nd1,nd3)) end
			  | NOTEQUALS :: ts2 => let val (ts3,nd3) = relationalExpression (ts2,beta) in equalityExpression' (ts3,Ast.BinaryExpr(Ast.NOT_EQUALS,nd1,nd3)) end
			  | STRICTEQUALS :: ts2 => let val (ts3,nd3) = relationalExpression (ts2,beta) in equalityExpression' (ts3,Ast.BinaryExpr(Ast.STRICT_EQUALS,nd1,nd3)) end
			  | STRICTNOTEQUALS :: ts2 => let val (ts3,nd3) = relationalExpression (ts2,beta) in equalityExpression' (ts3,Ast.BinaryExpr(Ast.STRICT_NOT_EQUALS,nd1,nd3)) end
			  | _ => (trace(["<< equalityExpression"]);(ts1,nd1))
		
    in
        equalityExpression' (ts1,nd1)
    end

(*
	BitwiseAndExpression(beta)    
    	EqualityExpression(beta)
	    BitwiseAndExpressionr(beta)  &  EqualityExpression(beta)

	right recursive: (see pattern of MultiplicativeExpression)
*)

and bitwiseAndExpression (ts, beta)=
    let val _ = trace([">> bitwiseAndExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = equalityExpression (ts,beta)
		fun bitwiseAndExpression' (ts1,nd1) =
			case ts1 of
				BITWISEAND :: ts2 => let val (ts3,nd3) = equalityExpression (ts2,beta) in bitwiseAndExpression' (ts3,Ast.BinaryExpr(Ast.BITWISE_AND,nd1,nd3)) end
			  | _ => (trace(["<< bitwiseAnd"]);(ts1,nd1))
		
    in
        bitwiseAndExpression' (ts1,nd1)
    end

(*
	BitwiseXorExpressionb    
    	BitwiseAndExpressionb
	    BitwiseXorExpressionb  ^  BitwiseAndExpressionb

	right recursive: (see pattern of MultiplicativeExpression)
*)

and bitwiseXorExpression (ts, beta)=
    let val _ = trace([">> bitwiseXorExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = bitwiseAndExpression (ts,beta)
		fun bitwiseXorExpression' (ts1,nd1) =
			case ts1 of
				BITWISEXOR :: ts2 => let val (ts3,nd3) = bitwiseAndExpression (ts2,beta) in bitwiseXorExpression' (ts3,Ast.BinaryExpr(Ast.BITWISE_XOR,nd1,nd3)) end
			  | _ => (trace(["<< bitwiseXor"]);(ts1,nd1))
    in
        bitwiseXorExpression' (ts1,nd1)
    end

(*
	BitwiseOrExpressionb    
    	BitwiseXorExpressionb
	    BitwiseOrExpressionb  |  BitwiseXorExpressionb
*)

and bitwiseOrExpression (ts, beta)=
    let val _ = trace([">> bitwiseOrExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = bitwiseXorExpression (ts,beta)
		fun bitwiseOrExpression' (ts1,nd1) =
			case ts1 of
				BITWISEOR :: ts2 => let val (ts3,nd3) = bitwiseXorExpression (ts2,beta) in bitwiseOrExpression' (ts3,Ast.BinaryExpr(Ast.BITWISE_OR,nd1,nd3)) end
			  | _ => (trace(["<< bitwiseAnd"]);(ts1,nd1))
		
    in
        bitwiseOrExpression' (ts1,nd1)
    end

(*
	LogicalAndExpressionb    
    	BitwiseOrExpressionb
	    LogicalAndExpressionb  &&  BitwiseOrExpressionb
*)

and logicalAndExpression (ts, beta)=
    let val _ = trace([">> logicalAndExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = bitwiseOrExpression (ts,beta)
		fun logicalAndExpression' (ts1,nd1) =
			case ts1 of
				LOGICALAND :: ts2 => let val (ts3,nd3) = bitwiseOrExpression (ts2,beta) in logicalAndExpression' (ts3,Ast.BinaryExpr(Ast.LOGICAL_AND,nd1,nd3)) end
			  | _ => (trace(["<< logicalAndExpression"]);(ts1,nd1))
		
    in
        logicalAndExpression' (ts1,nd1)
    end

(*
	LogicalXorExpressionb    
    	LogicalAndExpressionb
	    LogicalXorExpressionb  ^^  LogicalAndExpressionb
*)

and logicalXorExpression (ts, beta) =
    let val _ = trace([">> logicalXorExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = logicalAndExpression (ts,beta)
		fun logicalXorExpression' (ts1,nd1) =
			case ts1 of
				LOGICALXOR :: ts2 => let val (ts3,nd3) = logicalAndExpression (ts2,beta) in logicalXorExpression' (ts3,Ast.BinaryExpr(Ast.LOGICAL_XOR,nd1,nd3)) end
			  | _ => (trace(["<< logicalXorExpression"]);(ts1,nd1))
		
    in
        logicalXorExpression' (ts1,nd1)
    end

(*
	LogicalOrExpressionb    
    	LogicalXorExpressionb
	    LogicalOrExpressionb  ||  LogicalXorExpressionb

*)

and logicalOrExpression (ts, beta) =
    let val _ = trace([">> logicalOrExpression with next=",tokenname(hd(ts))]) 
		val (ts1,nd1) = logicalXorExpression (ts,beta)
		fun logicalOrExpression' (ts1,nd1) =
			case ts1 of
				LOGICALXOR :: ts2 => let val (ts3,nd3) = logicalXorExpression (ts2,beta) in logicalOrExpression' (ts3,Ast.BinaryExpr(Ast.LOGICAL_XOR,nd1,nd3)) end
			  | _ => (trace(["<< logicalOrExpression"]);(ts1,nd1))
		
    in
        logicalOrExpression' (ts1,nd1)
    end

(*
	ConditionalExpression(ALLOWLIST, beta)    
    	ExpressionClosure(beta)
	    LetExpression(beta)
    	YieldExpression(beta)
	    LogicalOrExpression(beta)
    	LogicalOrExpression(beta)  ?  AssignmentExpression(ALLOWLIST,beta)  :  AssignmentExpression(ALLOWLIST,beta)


	ConditionalExpression(NOLIST, beta)    
    	SimpleYieldExpression
	    LogicalOrExpression(beta)
    	LogicalOrExpression(beta)  ?  AssignmentExpression(ALLOWLIST,beta) :  AssignmentExpression(NOLIST,beta)
    
*)

and conditionalExpression (ts,ALLOWLIST,beta) =
    let val _ = trace([">> conditionalExpression with next=",tokenname(hd(ts))])
    in case ts of
(*        FUNCTION :: _ => expressionClosure(ts,beta) *)
        LET :: _ => letExpression(ts,beta)
	  | YIELD :: _ => yieldExpression(ts,beta)
      | _ => 
			let
				val (ts2,nd2) = logicalOrExpression(ts,beta)
			in case ts2 of
				QUESTIONMARK :: ts3 => 
					let
						val (ts4,nd4) = assignmentExpression(ts3,ALLOWLIST,beta)
					in case ts4 of
						COLON :: ts5 =>
							let
								val (ts6,nd6) = assignmentExpression(ts5,ALLOWLIST,beta)
							in
								(ts6,nd6)
							end
					  | _ => raise ParseError							
					end
			  | _ => (ts2,nd2)
			end
		end
 
  | conditionalExpression (ts,NOLIST,beta) =
    let val _ = trace([">> conditionalExpression with next=",tokenname(hd(ts))])
    in case ts of
	    YIELD :: _ => yieldExpression(ts,beta)
      | _ => 
			let
				val (ts2,nd2) = logicalOrExpression(ts,beta)
			in case ts2 of
				QUESTIONMARK :: ts3 => 
					let
						val (ts4,nd4) = assignmentExpression(ts3,ALLOWLIST,beta)
					in case ts4 of
						COLON :: ts5 =>
							let
								val (ts6,nd6) = assignmentExpression(ts5,ALLOWLIST,beta)
							in
								(ts6,nd6)
							end
					  | _ => raise ParseError							
					end
			  | _ => (ts2,nd2)
			end
		end

(*

*)

(*

NonAssignmentExpression(allowLet, beta)   
    ExpressionClosure(beta)
    LetExpression(beta)
    YieldExpression(beta)
    LogicalOrExpression(beta)
    LogicalOrExpression(beta)  ?  NonAssignmentExpression(allowLet, beta)  :  NonAssignmentExpression(allowLet, beta)
    
NonAssignmentExpression(noLet, beta)    
    SimpleYieldExpression
    LogicalOrExpression(beta)
    LogicalOrExpression(beta)  ?  NonAssignmentExpression(allowLet, beta)  :  NonAssignmentExpression(noLet, beta)

*)


and nonAssignmentExpression (ts,ALLOWLIST,beta) = raise ParseError
  | nonAssignmentExpression (ts,NOLIST,beta) = raise ParseError

(*

LetExpression(beta)    
    let  (  LetBindingList  )  ListExpression(beta)
    
*)

and letExpression (ts,beta) =
    let val _ = trace([">> letExpression with next=",tokenname(hd(ts))])
	in case ts of
		LET :: LEFTPAREN::ts1 => 
			let
				val (ts2,nd2) = letBindingList (ts1)
			in 
			case ts2 of
				RIGHTPAREN :: ts3 =>
					let
				        val (ts4,nd4) = listExpression(ts3,beta)
					in
						(ts4,nd4)
					end
 			  |	_ => raise ParseError
			end
	  | _ => raise ParseError
	end

(*

LetBindingList    
    �empty�
    NonemptyLetBindingList
    
*)

and letBindingList (ts) =
	let
	in case ts of
		RIGHTPAREN :: _ => (ts,Ast.ListExpr [])
	  | _ => (* nonemptyLetBindingList = *) raise ParseError
	end


(*

NonemptyLetBindingList    
    VariableBindingallowIn
    VariableBindingallowIn  ,  NonemptyLetBindingList
    
*)

(*

ExpressionClosure(beta)   
    function  FunctionSignature  ListExpression(beta)
    
*)

and expressionClosure (ts,beta) = raise ParseError

(*

YieldExpressionb    
    yield
    yield  [no line break]  ListExpressionb
    
*)

and yieldExpression (ts,beta) =
	case ts of
		YIELD :: ts1 => 
			let
			in case ts1 of
				(SEMICOLON :: _ | RIGHTBRACE :: _ | RIGHTPAREN :: _) => (ts1,Ast.YieldExpr NONE)
			  | _ => 
					let
						val (ts2,nd2) = listExpression(ts1,beta)
					in
						(ts2,Ast.YieldExpr(SOME nd2))
					end
			end
	  | _ => raise ParseError

(*

SimpleYieldExpression    
    yield
    
*)

and simpleYieldExpression ts =
	case ts of
		YIELD :: ts1 => (ts1,Ast.YieldExpr NONE)
	  | _ => raise ParseError

(*

AssignmentExpression (a,b)    
    ConditionalExpression (a,b)
    PostfixExpression  =  AssignmentExpression(a,b)
    PostfixExpression  CompoundAssignment  AssignmentExpression (a,b)
    PostfixExpression  LogicalAssignment  AssignmentExpression (a,b)
    TypedPattern  =  AssignmentExpression (a,b)
    
*)

and assignmentExpression (ts,a,b) :(token list * Ast.expr) = 
    let val _ = trace([">> assignmentExpression with next=",tokenname(hd(ts))]) 
    in case ts of
		LEFTBRACE :: _ => 
			let
				val (ts1,nd1) = objectLiteral ts
			in case ts1 of
				ASSIGN :: _ => 
					let
						val (ts2,nd2) = assignmentExpression(tl ts1,a,b)						
					in

					    (trace(["<< assignmentExpression with next=",tokenname(hd(ts2))]);
								(ts2,Ast.BinaryExpr(Ast.ASSIGN,Ast.LiteralExpr nd1,nd2)))

					end
			  | _ => (ts1,Ast.LiteralExpr nd1)
			end
	  | _ => 
	    	let
				val (ts1,nd1) = conditionalExpression(ts,a,b)
			in case (ts1,nd1) of
				(ASSIGN :: ts2, Ast.Ref {...}) => (* check for proper lhs expression *)
					let
						val (ts3,nd3) = assignmentExpression(ts2,a,b)						
					in case ts1 of
						ASSIGN :: _ => (ts3,Ast.BinaryExpr(Ast.ASSIGN,nd1,nd3))
					  | _ => (trace(["<< assignmentExpression"]);(ts1,nd1))
					end
			  | (ASSIGN :: ts2, _) => raise ParseError
			  | _ => (trace(["<< assignmentExpression with next=",tokenname(hd(ts1))]);(ts1,nd1))
			end

    end
(*

CompoundAssignment    
    *=
    /=
    %=
    +=
    -=
    <<=
    >>=
    >>>=
    &=
    ^=
    |=
    
*)

(*

LogicalAssignment    
    &&=
    ^^=
    ||=
    
*)

and logicalAssignment ts =
    raise ParseError

(*

ListExpression(beta)    
    AssignmentExpression(beta)
    ListExpression(beta)  ,  AssignmentExpression(beta)

right recursive:

ListExpression(beta)    
    AssignmentExpression(beta) ListExpressionPrime(beta)
    
ListExpressionPrime(beta)    
    �empty�
    , AssignmentExpression(beta) ListExpressionPrime(beta)

*)

and listExpression (ts,beta) = 
    let
		fun listExpressionPrime (ts,nd1,beta) =
	    	let
		    in case ts of
    		    COMMA :: ts1 =>
					let
            			val (ts2,nd2) = assignmentExpression(ts1,ALLOWLIST,beta)
	               		val (ts3,nd3) = listExpressionPrime(ts2,nd2,beta)
	    	      	in
    	    	     	(ts3, nd1 :: nd3)
	    	      	end
	    	  | _ => (ts, nd1 :: [])
		    end
        val (ts1,nd1) = assignmentExpression(ts,ALLOWLIST,beta)
        val (ts2,nd2) = listExpressionPrime(ts1,nd1,beta)
    in
        (ts2, Ast.ListExpr nd2)
    end

(*

Pattern    
    ObjectPattern
    ArrayPattern
    
*)

and pattern ts =
	let
	in case ts of
		LEFTBRACE :: _ => objectPattern ts
	  | LEFTBRACKET :: _ => arrayPattern ts
	  | _ => raise ParseError
	end

(*
	ObjectPattern    
    	{  DestructuringFieldList  }
*)

and objectPattern ts =
	let
	in case ts of
		LEFTBRACE :: ts =>
			let
				val (ts1,nd1) = destructuringFieldList ts
			in case ts1 of
				RIGHTBRACE :: _ => (tl ts1,Ast.ObjectPattern nd1)
			  | _ => raise ParseError
			end
	end

(*
	DestructuringFieldList    
    	DestructuringField
	    DestructuringFieldList  ,  DestructuringField

    refactored
*)

and destructuringFieldList ts =
	let
		fun destructuringFieldList' ts =
			let
			in case ts of
				COMMA :: _ =>
					let
						val (ts1,nd1) = destructuringField (tl ts)
						val (ts2,nd2) = destructuringFieldList' (ts1)
					in case ts of
					    _ => (ts2,nd1::nd2)
					end
			  | _ => (ts,[])
			end
		val (ts1,nd1) = destructuringField ts
		val (ts2,nd2) = destructuringFieldList' ts1
	in
		(ts2,nd1::nd2)
	end

(*
	DestructuringField    
    	NonAttributeQualifiedIdentifier  :  Pattern
	    NonAttributeQualifiedIdentifier  :  PostfixExpression
*)

and destructuringField ts =
	let
		val (ts1,nd1) = nonAttributeQualifiedIdentifier ts
	in case ts1 of
		COLON :: (LEFTBRACE | LEFTBRACKET) :: _ => 
			let
				val (ts2,nd2) = pattern (tl ts1)
			in
				(ts2,{name=Ast.Ref {base=NONE,ident=nd1},ptrn=nd2})
			end
	  | COLON :: _ => 
			let
				val (ts2,nd2) = postfixExpression (tl ts1)
			in
				(ts2,{name=Ast.Ref {base=NONE,ident=nd1},ptrn=Ast.SimplePattern nd2})
			end
	  | _ => raise ParseError
	end

(*
	ArrayPattern    
    	[  DestructuringElementList  ]
*)

and arrayPattern ts =
	let
	in case ts of
		LEFTBRACKET :: _ => 
			let
				val (ts1,nd1) = destructuringElementList (tl ts)
			in case ts1 of
				RIGHTBRACKET :: _ => (tl ts1,Ast.ArrayPattern nd1)
			end
	  | _ => raise ParseError
	end

(*
	DestructuringElementList    
    	�empty�
	    DestructuringElement
    	, DestructuringElementList
	    DestructuringElement , DestructuringElementList
*)

and destructuringElementList (ts) =
    let val _ = trace([">> destructuringElementList with next=",tokenname(hd(ts))]) 
	in case ts of
		RIGHTBRACKET :: _ => (ts,[])
	  | COMMA :: _ => 
			let
				val (ts1,nd1) = destructuringElementList (tl ts)
			in
				(ts1,Ast.SimplePattern(Ast.LiteralExpr(Ast.LiteralUndefined)) :: nd1)
			end
	  | _ =>
			let
				val (ts1,nd1) = destructuringElement (ts)
			in case ts1 of
				COMMA :: _ =>
					let
						val (ts2,nd2) = destructuringElementList (tl ts1)
					in
						(ts2,nd1::nd2)
					end
			  | _ => (ts1,nd1::[])
			end
	end

(*
	DestructuringElement    
    	Pattern
	    PostfixExpression
*)

and destructuringElement ts =
    let val _ = trace([">> destructuringElement with next=",tokenname(hd(ts))]) 		
	in case ts of
		(LEFTBRACE | LEFTPAREN) :: _ => pattern ts
	  | _ => 
			let
				val (ts1,nd1) = postfixExpression ts
			in
				(ts1,Ast.SimplePattern(nd1))
			end
	end

(*

TYPE EXPRESSIONS    
    
*)

(*

FunctionType    
    function  FunctionSignature
    
*)

and functionType ts =
    let val _ = trace([">> functionType with next=",tokenname(hd(ts))]) 		
	in case ts of
		FUNCTION :: _ => 
			let
				val (ts1,Ast.FunctionSignature{typeparams,params,resulttype}) = functionSignature (tl ts)
				fun paramtypes (params:Ast.formal list):Ast.tyExpr option list =
					case params of
						[] => []
					  | _ => 
							let
								val _ = log(["paramtypes"]);
								val {ty,... } = hd params
							in
								ty :: paramtypes (tl params)
							end
			in
				trace(["<< functionType with next=",tokenname(hd ts1)]);
				(ts1,Ast.FunctionType {paramTypes=paramtypes params,returnType=resulttype,boundThisType=NONE,hasRest=false})
			end
	end

(*

UnionType    
    (  TypeExpressionList  )
    
*)

(*

RecordType    
    {  FieldTypeList  }
    
*)

(*

FieldTypeList    
    �empty�
    NonemptyFieldTypeList
    
*)

(*

NonemptyFieldTypeList    
    FieldType
    FieldType  ,  NonemptyFieldTypeList
    
*)

(*

FieldType    
    FieldName  :  TypeExpression
    
*)

(*

ArrayType    
    [  ElementTypeList  ]
    
*)

(*

ElementTypeList    
    �empty�
    TypeExpression
    ,  ElementTypeList
    TypeExpression  ,  ElementTypeList
    
*)

(*

TypeExpression    
    TypeIdentifier
    TypeIdentifier  !
    TypeIdentifier  ?
    FunctionType
    UnionType
    RecordType
    ArrayType
    
*)

and typeExpression ts =
    let val _ = trace([">> typeExpression with next=",tokenname(hd ts)])
    in case ts of

       FUNCTION :: _ => 
			let
				val (ts1,nd1) = functionType ts
			in
				trace(["<< typeExpression with next=",tokenname(hd ts)]);
				(ts1,nd1)
			end
(*
       LEFTPAREN :: ts1 => unionType ts
       LEFTBRACE :: ts1 => recordType ts
       LEFTBRACKET :: ts1 => arrayType ts
*)
	 | _ => 
            let
                val (ts1,nd1) = typeIdentifier ts
				val rf = Ast.Ref {base=NONE,ident=nd1}
            in
                (ts1,Ast.UnresolvedType(rf)) (* Ast.PrimaryType {name=nd1,annotation=Ast.NAMED}) *)
            end
    end

(*

TypeExpressionList    
    TypeExpression
    TypeExpressionList  ,  TypeExpression

*)



(* STATEMENTS *)

(*

Statementw    
    Block
    BreakStatement Semicolonw
    ContinueStatement Semicolonw
    DefaultXMLNamespaceStatement Semicolonw
    DoStatement Semicolonw
    ExpressionStatement Semicolonw
    ForStatementw
    IfStatementw
    LabeledStatementw
    LetStatementw
    ReturnStatement Semicolon(omega)
    SuperStatement Semicolonw
    SwitchStatement
    ThrowStatement Semicolonw
    TryStatement
    WhileStatementw
    WithStatementw
    
Substatementw    
    EmptyStatement
    Statementw
    
Semicolonabbrev     
    ;
    VirtualSemicolon
    �empty�
    
SemicolonnoShortIf    
    ;
    VirtualSemicolon
    �empty�
    
Semicolonfull    
    ;
    VirtualSemicolon

*)

and statement (ts,omega) =
	let
	in case ts of
	    RETURN :: _ =>
			let
				val (ts1,nd1) = returnStatement (ts)
(* todo 				val (ts2,_) = semicolon (ts1,omega) *)
			in
				(ts1,nd1)
			end
	  | _ =>
			let
				val (ts1,nd1) = expressionStatement (ts)
(* todo 				val (ts2,_) = semicolon (ts1,omega) *)
			in
				(ts1,nd1)
			end
	end


(*
    
EmptyStatement     
    ;

*)

and emptyStatement ts =
    let
    in case ts of
		SEMICOLON :: ts1 => (ts1,Ast.EmptyStmt)
	  | _ => raise ParseError
    end

(*
    
ExpressionStatement    
    [lookahead !{ function, { }] ListExpression (allowLet,allowIn)

*)

and expressionStatement ts =
    let
        val _ = trace([">> expressionStatement with next=", tokenname(hd ts)])
        val (ts1,nd1) = listExpression(ts,ALLOWIN)
    in
        (ts1,Ast.ExprStmt(nd1))
    end

(*
    
SuperStatement    
    super Arguments
    
*)

(*

Block    
    { Directives }

*)

and block (ts) : (token list * Ast.block) =
    let val _ = trace([">> block with next=", tokenname(hd ts)])
    in case ts of
        LEFTBRACE :: RIGHTBRACE :: ts1 => (ts1,Ast.Block{directives=[],defns=[],stmts=[]})
      | LEFTBRACE :: ts1 =>
            let
                val (ts2,nd2) = directives ts1
            in case ts2 of
                RIGHTBRACE :: ts3 => (ts3,Ast.Block{directives=nd2,defns=[],stmts=[]})
			  | _ => raise ParseError
            end
	  | _ => raise ParseError
    end

(*
    
LabeledStatementw    
    Identifier : Substatementw
    
IfStatementabbrev    
    if ParenListExpression Substatementabbrev
    if ParenListExpression SubstatementnoShortIf else Substatementabbrev
    
IfStatementfull    
    if ParenListExpression Substatementfull
    if ParenListExpression SubstatementnoShortIf else Substatementfull
    
IfStatementnoShortIf    
    if ParenListExpression SubstatementnoShortIf else SubstatementnoShortIf
    
SwitchStatement    
    switch ParenListExpression { CaseElements }
    switch  type  (  TypedIdentifierallowIn  =  AssignmentExpressionallowIn  )  {  TypeCaseElements  }
    
CaseElements    
    �empty�
    CaseLabel
    CaseLabel CaseElementsPrefix CaseElementabbrev
    
CaseElementsPrefix    
    �empty�
    CaseElementsPrefix CaseElementfull
    
CaseElementw    
    Directivew
    CaseLabel
    
CaseLabel    
    case ListExpressionallowIn :
    default :
    
TypeCaseElements    
    TypeCaseElement
    TypeCaseElements  TypeCaseElement
    
TypeCaseElement    
    case  (  TypedIdentifierallowIn  )  Block
    case  (  TypedPattern  )  Block
    default  Block
    
DoStatement    
    do Substatementabbrev while ParenListExpression
    
WhileStatementw    
    while ParenListExpression Substatementw
    
ForStatementw    
    for  (  ForInitialiser  ;  OptionalExpression  ;  OptionalExpression  )  Substatementw
    for  (  ForInBinding  in  ListExpressionallowIn  )  Substatementw
    for  each  ( ForInBinding  in  ListExpressionallowIn  )  Substatementw
    
ForInitialiser    
    �empty�
    ListExpressionnoIn
    VariableDefinitionnoIn
    
ForInBinding    
    PostfixExpression
    Pattern
    VariableDefinitionKind VariableBindingnoIn
    
OptionalExpression    
    ListExpressionallowIn
    �empty�
    
LetStatementw    
    let  (  LetBindingList  )  Substatementw
    
WithStatementw    
    with  (  ListExpressionallowIn  )  Substatementw
    with  (  ListExpressionallowIn  :  TypeExpression  )  Substatementw
    
ContinueStatement    
    continue
    continue [no line break] Identifier
    
BreakStatement    
    break
    break [no line break] Identifier
*)

(*    
ReturnStatement    
    return
    return [no line break] ListExpressionallowIn
*)

and returnStatement ts =
	let
	in case ts of
		RETURN :: (SEMICOLON | RIGHTBRACE) :: _ => (tl ts,Ast.ReturnStmt (Ast.LiteralExpr Ast.LiteralUndefined))
	  | RETURN :: _ =>
			let
				val (ts1,nd1) = listExpression(tl ts, ALLOWIN)
			in
				(ts1,Ast.ReturnStmt nd1)
			end
	end

(*    
ThrowStatement     
    throw  ListExpressionallowIn
    
TryStatement    
    try Block CatchClauses
    try Block CatchClausesOpt finally Block
    
CatchClausesOpt    
    �empty�
    CatchClauses
    
CatchClauses    
    CatchClause
    CatchClauses CatchClause
    
CatchClause    
    catch  (  Parameter  )  Block
    
DefaultXMLNamespaceStatement    
    default  xml  namespace = NonAssignmentExpressionallowLet, allowIn

*)
    
(* DIRECTIVES *)

(*
	Directive(omega)    
    	EmptyStatement
	    Statement(omega)
    	AnnotatableDirective(omega)
	    Attributes [no line break] AnnotatableDirective(omega)
    	IncludeDirective Semicolon(omega)    
*)

and directive (ts,omega) =
    let val _ = trace([">> directive with next=", tokenname(hd ts)])
	in case ts of
		SEMICOLON :: _ => 
			let
				val (ts1,nd1) = emptyStatement ts
			in
				(ts1,Ast.Statement(nd1))
			end
	  | (VAR | FUNCTION ) :: _ => 
			let
				val (ts1,nd1) = annotatableDirective (ts,omega)
			in
				(ts1,Ast.Definition(nd1))
			end
	  | _ => 
			let
				val (ts1,nd1) = statement (ts,omega)
			in
				(ts1,Ast.Statement(nd1))
			end
	end

(*
	AnnotatableDirective(omega)
    	VariableDefinition(allowIn) Semicolon(omega)
	    FunctionDefinition
    	ClassDefinition
	    InterfaceDefinition
    	NamespaceDefinition Semicolon(omega)
	    TypeDefinition Semicolon(omega)

	Attributes    
    	Attribute
	    Attribute [no line break] Attributes
    
	Attribute    
    	SimpleTypeIdentifier
	    ReservedNamespace
    	dynamic
	    final
    	native
	    override
    	prototype
	    static
    	[  AssignmentExpression(allowLet, allowIn)  ]
*)

and annotatableDirective (ts,omega) : token list * Ast.definition list  =
    let val _ = trace([">> annotatableDirective with next=", tokenname(hd ts)])
	in case ts of
		VAR :: _ => variableDefinition (ts,ALLOWIN)
	  | _ => raise ParseError
	end

(*
	Directives    
    	�empty�
	    DirectivesPrefix Directive(abbrev)
    
	DirectivesPrefix    
    	�empty�
	    Pragmas
    	DirectivesPrefix Directive(full)
*)

and directives (ts) : (token list * Ast.directive list) =
	let
	in case ts of
		RIGHTBRACE :: _ => (ts,[])
	  | _ => 
			let
				val (ts1,nd1) = directive (ts,ABBREV)
			in
				(ts1,[nd1])
			end
	end

(*
IncludeDirective    
    include  [no line break]  StringLiteral
    
Pragmas    
    Pragma
    Pragmas  Pragma
    
Pragma    
    UsePragma  Semicolon(full)
    ImportPragma  Semicolon(full)
    
UsePragma    
    use  PragmaItems
    
PragmaItems    
    PragmaItem
    PragmaItems  ,  PragmaItem
    
PragmaItem    
    PragmaIdentifier
    PragmaIdentifier  PragmaArgument
    
PragmaIdentifier    
    decimal
    default namespace
    double
    int
    namespace
    Number
    rounding
    standard
    strict
    uint
    
PragmaArgument    
    true
    false
    NumberLiteral
    -  NumberLiteral
    StringLiteral
    SimpleTypeIdentifier
    
ImportPragma    
    import  ImportName
    import  Identifier  =  ImportName
    
ImportName    
    PackageIdentifier  .  PropertyIdentifier

*)
    
(* DEFINITIONS *)    

(*
    
VariableDefinitionb    
    VariableDefinitionKind  VariableBindingListallowLet, b
    
VariableDefinitionKind    
    const
    let
    let const
    var
    
VariableBindingLista, b    
    VariableBindinga, b
    VariableBindingListnoLet, b  ,  VariableBindinga, b
    
VariableBindinga, b    
    TypedIdentifier
    TypedIdentifierb VariableInitialisationa, b
    TypedPattern VariableInitialisationa, b
    
VariableInitialisationa, b    
    =  AssignmentExpressiona, b


     and varDefn =
         SimpleDefn of { tag: varDefnTag,
                         init: expr option,
                         attrs: attributes,
                         name: ident,
                         ty: tyExpr option }

       | DestructDefn of { tag: varDefnTag,
                           init: expr option,
                           attrs: attributes,
                           ptrn: pattern,
                           ty: tyExpr option }

       | DestructuringDefn of { tag: varDefnTag,
                                init: expr option,
                                attrs: attributes,
                                temp: ident,
                                postInit: expr option,
                                names: ident list,
                                ty: tyExpr option }
*)

and variableDefinition (ts,beta) =
	let
	in case ts of
		CONST :: _ => variableBindingList (tl ts,Ast.CONST,ALLOWLIST,beta)
	end

and variableBindingList (ts,tag,alpha,beta) = 
    let
		fun variableBindingListPrime (ts,tag,alpha,beta) =
	    	let
		    in case ts of
    		    COMMA :: _ =>
					let
            			val (ts1,nd1) = variableBinding(tl ts,tag,alpha,beta)
	               		val (ts2,nd2) = variableBindingListPrime(ts1,tag,alpha,beta)
	    	      	in
    	    	     	(ts2, Ast.VariableDefn nd1 :: nd2)
	    	      	end
	    	  | _ => (ts, [])
		    end
   			val (ts1,nd1) = variableBinding(tl ts,tag,alpha,beta)
       		val (ts2,nd2) = variableBindingListPrime(ts1,tag,alpha,beta)
    in
        (ts2, Ast.VariableDefn nd1 :: nd2)
    end

and variableBinding (ts,tag,alpha,beta) = 
	let
	in case ts of
		(LEFTBRACE | LEFTBRACKET) :: _ =>
			let
				val (ts1,{ptrn,ty}) = typedPattern ts
			in case ts1 of
				ASSIGN :: _ =>
					let
						val (ts2,nd2) = assignmentExpression (tl ts1,alpha,beta)
					in
						(ts2, Ast.DestructDefn { tag = tag,
                         	init = SOME nd2,
                         	attrs = Ast.EmptyAttributes,
                         	ptrn = ptrn ,
                         	ty = ty } )
					end
			end
	  | _ => 
			let
				val (ts1,nd1) = typedIdentifier ts
			in case ts1 of
				ASSIGN :: _ =>
					let
						val (ts2,nd2) = assignmentExpression (tl ts1,alpha,beta)
					in
						(ts2, Ast.SimpleDefn { tag = tag,
                         init = SOME nd2,
                         attrs = Ast.EmptyAttributes,
                         name = #name nd1,
                         ty = #ty nd1 } )
					end
			  | _ => (ts1, Ast.SimpleDefn { tag = tag,
                         init = NONE,
                         attrs = Ast.EmptyAttributes,
                         name = #name nd1,
                         ty = #ty nd1 } )
			end
	end

(*

FunctionDefinition    
    function  FunctionName  FunctionCommon
    let  function  FunctionName  FunctionCommon
    
FunctionName    
    Identifier
    OperatorName
    to  [no line break]  Identifier
    get  [no line break]  PropertyIdentifier
    set  [no line break]  PropertyIdentifier
    call  [no line break]  PropertyIdentifier
    
OperatorName [one of]    
    +   -   ~   *   /   %   <   >   <=   >=   ==   <<   >>   >>>   &   |   ===   !=   !==
    
ClassDefinition    
    class  ClassName  Inheritance Block
    
Inheritance    
    �empty�
    extends TypeIdentifier
    implements TypeIdentifierList
    extends TypeIdentifier implements TypeIdentifierList
    
TypeIdentifierList    
    TypeIdentifier
    TypeIdentifier  ,  TypeIdentifierList
    
InterfaceDefinition    
    interface  ClassName  ExtendsList Block
    
ExtendsList    
    �empty�
    extends TypeIdentifierList
    
NamespaceDefinition    
    namespace NamespaceBinding
    
NamespaceBinding    
    Identifier NamespaceInitialisation
    
NamespaceInitialisation    
    �empty�
    = StringLiteral
    = SimpleTypeIdentifier
    
TypeDefinition    
    type  TypeBinding
    
TypeBinding    
    Identifier  TypeInitialisation
    
TypeInitialisation    
    =  TypeExpression
*)

(*
    
Program    
    Directives
    PackageDefinition Program

*)
    
and program ts =
    let
       val _ = trace([">> program with next=",tokenname(hd(ts))])
    in case ts of
        PACKAGE :: tr => 
			let 
			    val (tr2, pkgs) = packageDefinition tr
			in
			    (tr2, {packages=[pkgs], body=(Ast.Block {directives=[],
						     defns=[],
						     stmts=[]})})
			end
      | _ => 
			let
			    val (tr2, directives) = directives ts
			in
			    (tr2, {packages=[], body=(Ast.Block {directives=directives,
					   defns=[],
					   stmts=[]})})
			end
    end

(*

PackageDefinition    
    PackageAttributes package PackageNameOpt Block
    
PackageAttributes    
    internal
    �empty�
    
PackageNameOpt    
    �empty�
    PackageName
    
PackageName [create a lexical PackageIdentifier with the sequence of characters that make a PackageName]    
    Identifier
    PackageName  .  Identifier
    
ClassName    
    ParameterisedClassName
    ParameterisedClassName  !
    
ParameterisedClassName    
    Identifier
    Identifier  TypeParameters

*)


and typeExpressionList ts = raise ParseError

(*

*)

and packageDefinition ts = raise ParseError

fun mkReader filename = 
    let
        val stream = TextIO.openIn filename
    in
        fn _ => case TextIO.inputLine stream of
                    SOME line => (log ["read line ", line]; line)
                  | NONE => ""
    end

(*
   scan to first < or /

   the scanner state includes the reader and a token stream.
   when the token stream is empty continue scanning in the current slash context until another key character is encountered.

   switch slash contexts at the normal points in the program.
*)

fun dumpTokens (ts,lst) =
	case ts of
		[] => rev lst
      | _ => dumpTokens(tl ts, tokenname(hd ts) :: "\n  " :: lst)

fun lexFile (filename : string) : (token list) = 
    let 
        val lexer = Lexer.makeLexer (mkReader filename)
	val tokens = Lexer.UserDeclarations.token_list lexer
    in
        log ("tokens:" :: dumpTokens(tokens,[])); 
        tokens
    end

fun parse ts =
    let 
	val (residual, result) = (program ts) 
	fun check_residual (EOL :: xs) = check_residual xs
	  | check_residual [EOF] = ()
	  | check_residual _ = raise ParseError
    in
	check_residual residual;
	log ["parsed all input, pretty-printing:"];
	Pretty.ppProgram result;
	result
    end

fun parseFile filename = 
    (log ["scanning ", filename]; (parse (lexFile filename) handle 
			ParseError => (log ["parse error"]; raise ParseError)
	      | Lexer.LexError => (log ["lex error"]; raise Lexer.LexError));
     log ["parsed ", filename, "\n"])

end (* Parser *)