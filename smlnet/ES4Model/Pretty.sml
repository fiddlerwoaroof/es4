(*
 * The following licensing terms and conditions apply and must be
 * accepted in order to use the Reference Implementation:
 * 
 *    1. This Reference Implementation is made available to all
 * interested persons on the same terms as Ecma makes available its
 * standards and technical reports, as set forth at
 * http://www.ecma-international.org/publications/.
 * 
 *    2. All liability and responsibility for any use of this Reference
 * Implementation rests with the user, and not with any of the parties
 * who contribute to, or who own or hold any copyright in, this Reference
 * Implementation.
 * 
 *    3. THIS REFERENCE IMPLEMENTATION IS PROVIDED BY THE COPYRIGHT
 * HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * End of Terms and Conditions
 * 
 * Copyright (c) 2007 Adobe Systems Inc., The Mozilla Foundation, Opera
 * Software ASA, and others.
 *)

structure Pretty =
struct

open Ast

fun pp s = TextIO.print (s ^ "\n")

(*
fun ppProgram (p : PROGRAM) = TextIO.print "<program>\n"

fun ppExpr (e : EXPR) = TextIO.print "<expr>\n"

fun ppStmt (s : STMT) = TextIO.print "<stmt>\n"

fun ppDefinition (s : DEFN) = TextIO.print "<defn>\n"

fun ppVarDefn (s : VAR_BINDING) = TextIO.print "<var defn>\n"
*)

val ppNamespace _ = pp "<namespace>"

val ppProgram _ = pp "<program>"

val ppExpr = pp "<expr>"

val ppStmt = pp "<stmt>"

val ppDefinition = pp "<defn>"

val ppVarDefn = pp "<var defn>"

val ppType = pp "<type>"

val ppBinop = pp "<binop>"

val ppNumericMode = pp "<numeric mode>"

val ppPragma = pp "<pragma>"

val ppFixtures = pp "<fixtures>"

val ppFixture = pp "<fixture>"

val ppFunc = pp "<func>"

end
