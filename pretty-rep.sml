structure PP = PPStreamFn(structure Token = StringToken
                          structure Device = SimpleTextIODev)

structure PrettyRep = struct

datatype smlDataRep =
         Ctor of string * (smlDataRep option)
       | Rec of (string * smlDataRep) list
       | List of smlDataRep list
       | Tuple of smlDataRep list
       | String of string
       | Ref of smlDataRep
       | Real of real
       | Bool of bool

fun ppSmlDataRep stream (rep : smlDataRep) =
    let
        fun nbsp _ = PP.nbSpace stream 1
	fun sp _ = PP.space stream 1
        fun ob _ = PP.openHVBox stream (PP.Rel 2)
        fun cb _ = PP.closeBox stream
        fun str s = PP.string stream s
        fun sub (r : smlDataRep) = ppSmlDataRep stream r
        fun sublist [] = ()
          | sublist (r::rs) = (sub r; List.app (fn x => (str ","; sp(); sub x)) rs)
    in
    case rep of
        Ctor (ctor, NONE) => str ctor
      | Ctor (ctor, SOME arg) => (ob(); str ctor; sp (); sub arg; cb())
      | Rec [] => str "{}"
      | Rec (row::rows) =>
        let
            fun doRow (n,v) = (str n; nbsp(); str "="; nbsp(); sub v)
        in
            (ob(); str "{"; nbsp(); doRow row;
             List.app (fn r => (str ","; sp(); doRow r)) rows;
             str "}"; cb())
        end

      | List rs => (ob(); str "["; sublist rs; str "]"; cb())
      | Tuple rs => (ob(); str "("; sublist rs; str ")"; cb())
      | String s => (str "\""; str (String.toString s); str "\"")
      | Ref r => (ob(); str "("; str "ref"; sp; sub r; str ")"; cb())
      | Bool true => str "true"
      | Bool false => str "false"
      | Real r => str (Real.toString r)
    end

end
