(* -*- mode: sml; mode: font-lock; tab-width: 4; insert-tabs-mode: nil; indent-tabs-mode: nil -*- *)
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
(* *)

structure DecimalNative = struct

open DecimalParams

val decop = _import "decop" : int * int * int * char array * char array * char array -> int;

fun rmToInt (rm:ROUNDING_MODE)
    : int =
    (case rm of
         Ceiling => 0
       | Floor => 1
       | Up => 2
       | Down => 3
       | HalfUp => 4
       | HalfDown => 5
       | HalfEven => 6);

fun opToInt (dop:DECIMAL_OPERATOR)
    : int =
    (case dop of
         Abs => 0
       | Add => 1
       | Compare => 2
       | CompareTotal => 3
       | Divide => 4
       | DivideInteger => 5
       | Exp => 6
       | Ln => 7
       | Log10 => 8
       | Max => 9
       | Min => 10
       | Minus => 11
       | Multiply => 12
       | Normalize => 13
       | Plus => 14
       | Power => 15
       | Quantize => 16
       | Remainder => 17
       | RemainderNear => 18
       | Rescale => 19
       | SameQuantum => 20
       | SquareRoot => 21
       | Subtract => 22
       | ToIntegralValue => 23);

val DECIMAL128_String = 43; (* from decimal128.h *)

fun arrayToList a = Array.foldr (op ::) [] a;

fun takeUntil p [] = []
  | takeUntil p (x::ls) = if (p x)
                          then []
                          else x::(takeUntil p ls);

fun stringToBuffer s =
    Array.fromList ((String.explode s) @ [#"\000"])

fun bufferToString b =
    String.implode (takeUntil (fn c => c = #"\000") (arrayToList b));

fun decErrorString n =
    (case n of
         1 => "bad precision number"
       | 2 => "bad rounding mode"
       | 3 => "bad operator code"
       | 4 => "invalid syntax"
       | 5 => "out of memory"
       | 6 => "decNumber completely wedged"
       | _ => "unknown error")

fun runOp (precision:int)
          (mode:ROUNDING_MODE)
          (operator:DECIMAL_OPERATOR)
          (left:DEC)
          (right:DEC option)
    : DEC =
    let
        val buffer = Array.tabulate (DECIMAL128_String, fn _ => #"\000")
        val Dec left = left
        val right = (case right of
                         NONE => "0"
                       | SOME (Dec s) => s)
    in
        (case decop (precision, rmToInt mode, opToInt operator, stringToBuffer left, stringToBuffer right, buffer) of
             0 => Dec (bufferToString buffer)
           | n => raise DecimalException (decErrorString n))
    end;

end;
