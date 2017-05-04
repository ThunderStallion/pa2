open Compile
open Runner
open Printf
open OUnit2

let t name program expected = name>::test_run program name expected;;
let te name program expected = name>::test_err program name expected;;

let forty = "let x = 40 in x"
let fals = "let x = false in x"
let tru = "let x = true in x"
let isbool1 = "isbool(true)"
let isbool2 = "isbool(10)"
let isnum1 = "isnum(false)"
let isnum2 = "isnum(24)"
let add1 = " add1(5)"
let sub1 = " sub1(4)"
let mult = "23 * 2"
let add2 = "42 + 3"
let minus = "4232 - 3"
let lt1 = "23 < 100"
let lt2 = "232 < 11"
let gt1 = "41 > 12"
let gt2 = "(42 + 31 ) > 45"
let eq = "11 == 11"
let eq2 = "5214241 == 23231231"
let comp1 = "(43 - 3) - 24 * 2"
let t_if = "let x = true in if x: 42 else: 13"
let elet1 = "let x = sub1(5), x = 3, x = 10, b = 2, b = 3, a = 2, a = 3 in y + 1"
let elet2 = "let x = 1 in (let x = 2 in x)"
let elet4 = "let x = 2 in let y = 3 in x +y"
let elet5 = "let x = 2, y = 3 in x + y"
let suite =
"suite">:::
 [
  t "elet5" elet5 "5";
  t "elet4" elet4 "5";
  t "elet2" elet2 "2";
  t "elet1" elet1 "Error: Compile error: Multiple bindings for variable identifier x \nMultiple bindings for variable identifier b\nMultiple bindings for variable identifier a\n\nUnbound identifier: y";
  t "t_if" t_if "42";
  t "comp1" comp1 "32";
  t "gt2" gt2 "true";
  t "eq2" eq2 "false";
  t "minus" minus "4229";
  t "lt1" lt1 "true";
  t "lt2" lt2 "false";
  t "gt1" gt1 "true";
  t "eq" eq "true";
  t "mult" mult "46";
  t "add2" add2 "45";
  t "add1" add1 "6";
  t "sub1" sub1 "3";

  t "isbool1" isbool1 "true";
  t "isbool2" isbool2 "false";
  t "isnum1" isnum1 "false";
  t "isnum2" isnum2 "true";
  t "forty" forty "40";
  t "fals" fals "false";
  t "tru" tru "true"; 
 
 ]
;;


let () =
  run_test_tt_main suite
;;
