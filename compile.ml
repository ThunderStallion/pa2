open Printf

type reg =
  | EAX
  | ESP

type size =
  | DWORD_PTR
  | WORD_PTR
  | BYTE_PTR

type arg =
  | Const of int
  | HexConst of int
  | Reg of reg
  | RegOffset of int * reg
  | Sized of size * arg

type instruction =
  | IMov of arg * arg
  | IAdd of arg * arg
  | ISub of arg * arg
  | IMul of arg * arg

  | IShr of arg * arg
  | IShl of arg * arg

  | IAnd of arg * arg
  | IOr of arg * arg
  | IXor of arg * arg

  | ILabel of string
  | IPush of arg
  | IPop of arg
  | ICall of string
  | IRet

  | ICmp of arg * arg
  | IJne of string
  | IJe of string
  | IJmp of string
  | IJno of string
  | IJo of string
  | IJl of string
  | IJg of string

type prim1 =
  | Add1
  | Sub1
  | IsNum
  | IsBool

type prim2 =
  | Plus
  | Minus
  | Times
  | Less
  | Greater
  | Equal

type expr =
  | ELet of (string * expr) list * expr
  | EPrim1 of prim1 * expr
  | EPrim2 of prim2 * expr * expr
  | EIf of expr * expr * expr
  | ENumber of int
  | EBool of bool
  | EId of string

let r_to_asm (r : reg) : string =
  match r with
    | EAX -> "eax"
    | ESP -> "esp"

let s_to_asm (s : size) : string =
  match s with
    | DWORD_PTR -> "DWORD"
    | WORD_PTR -> "WORD"
    | BYTE_PTR -> "BYTE"

let rec arg_to_asm (a : arg) : string =
  match a with
    | Const(n) -> sprintf "%d" n
    | HexConst(n) -> sprintf "0x%X" n 
    | Reg(r) -> r_to_asm r
    | RegOffset(n, r) -> if n>=0 then sprintf "[%s-%d]" (r_to_asm(r)) (n * 4)
                         else sprintf "[%s-%d]" (r_to_asm r) (n * -1 * 4)
    | Sized(s, a) -> sprintf "%s %s" (s_to_asm s) (arg_to_asm a)

let i_to_asm (i : instruction) : string =
  match i with
    | IMov(dest, value) ->
      sprintf "  mov %s, %s" (arg_to_asm dest) (arg_to_asm value)
    | IAdd(dest, to_add) ->
      sprintf "  add %s, %s" (arg_to_asm dest) (arg_to_asm to_add)
    | ISub(dest, to_sub) ->
      sprintf "  sub %s, %s" (arg_to_asm dest) (arg_to_asm to_sub)
    | IMul(dest, to_mul) ->
      sprintf "  imul %s, %s" (arg_to_asm dest) (arg_to_asm to_mul)
    | IAnd(dest, mask) ->
      sprintf "  and  %s, %s" (arg_to_asm dest) (arg_to_asm mask)
    | IOr(dest, mask) ->
      sprintf "  or %s, %s" (arg_to_asm dest) (arg_to_asm mask)
    | IXor(dest, mask) ->
      sprintf "  xor %s, %s" (arg_to_asm dest) (arg_to_asm mask)
    | IShr(dest, to_shift) ->
      sprintf "  shr %s, %s" (arg_to_asm dest) (arg_to_asm to_shift)
    | IShl(dest, to_shift) ->
      sprintf "  shl %s, %s" (arg_to_asm dest) (arg_to_asm to_shift)
    | ICmp(left, right) ->
      sprintf "  cmp %s, %s" (arg_to_asm left) (arg_to_asm right)
    | IPush(arg) ->
      sprintf "  push %s" (arg_to_asm arg)
    | IPop(arg) ->
      sprintf "  pop %s" (arg_to_asm arg)
    | ICall(str) ->
      sprintf "  call %s" (str)
    | ILabel(name) ->
      sprintf "%s:" name 
    | IJne(label) ->
      sprintf "jne near %s" label 
    | IJe(label) ->
      sprintf "je near %s" label 
    | IJno(label) ->
      sprintf "jno near %s" label 
    | IJo(label) ->
      sprintf "jo near %s" label 
    | IJmp(label) ->
      sprintf "jmp near %s" label 
    | IJl(label) ->
      sprintf "jl near %s" label 
    | IJg(label) ->
      sprintf "jg near %s" label 
    | IRet ->
      " ret"

let to_asm (is : instruction list) : string =
  List.fold_left (fun s i -> sprintf "%s\n%s" s (i_to_asm i)) "" is

let rec find ls x =
  match ls with
    | [] -> None
    | (y,v)::rest ->
      if y = x then Some(v) else find rest x

let count = ref 0
let gen_temp base =
  count := !count + 1;
  sprintf "temp_%s_%d" base !count

let const_true = HexConst(0xffffffff)
let const_false = HexConst(0x7fffffff)

(* You want to be using C functions to deal with error output here. *)
let throw_err code = [IPush(Sized(DWORD_PTR, Const(code))); ICall(("error"));]
let error_overflow = "error_overflow"
let error_non_int  = "error_non_int"
let error_non_bool = "error_non_bool"

let check_overflow = IJo(error_overflow)

let check_num = [
        IMov(RegOffset(1, ESP), Reg(EAX)); 
        IAnd(Reg(EAX), Sized(DWORD_PTR, HexConst(0x1)));
        ICmp(Reg(EAX), Sized(DWORD_PTR, HexConst(0x0)));
        IJne(error_non_int);
        IMov(Reg(EAX) , RegOffset(1,ESP));
       ] 

let check_nums arg1 arg2 = 
        [IMov(Reg(EAX), arg1) ] @ check_num 
        @ [IMov(Reg(EAX), arg2);] @ check_num 

let rec exist_once (target : 'a) (pile : 'a list) : bool =
  match pile with
    | [] -> false
    | head::tail -> if target = head then true else exist_once target tail

let rec exist_many (l : 'a list) : 'a option =
  match l with
    | [] -> None
    | [x] -> None
    | head::tail -> if (exist_once head tail) then Some(head) else exist_many tail



let rec well_formed_e (e : expr) (env : (string * int) list) : string list =
  match e with
    | ENumber(_)
    | EBool(_) -> []
    | EId(x) ->
      begin match find env x with
        | None -> ["Unbound identifier: " ^ x]
        | Some(_) -> []
      end
    | EPrim1(op, e) ->
      well_formed_e e env
    | EPrim2(op, left, right) ->
      (well_formed_e left env) @ (well_formed_e right env)
    | EIf(cond, thn, els) ->
      (well_formed_e cond env) @ (well_formed_e thn env)
      @ (well_formed_e thn env)
    | ELet(binds, body) -> 
      let vars = List.map fst binds in
      let bindings = List.map (fun x -> (x,1)) vars in
      let context = well_formed_e body (bindings @ env) in
      begin match exist_many vars with
        | None -> context
        | Some(name) -> 
            ("Multiple bindings for variable identifier " ^ name)::context
      end
    

     

let check (e : expr) : string list =
  match well_formed_e e [] with
    | [] -> []
    | errs -> failwith (String.concat "\n" errs)

let rec compile_expr (e : expr) (si : int) (env : (string * int) list) : instruction list =
  match e with
    | ENumber(n) ->
      [IMov(Reg(EAX), Const(n));
       IShl(Reg(EAX), Const(1))]
    | EBool(b) ->
      let c = if b then const_true else const_false in
      [ IMov(Reg(EAX), c) ]
    | EId(name) -> 
        begin match find env name with
            | Some(location) ->[IMov(Reg(EAX), RegOffset(location, ESP))]
            | None-> failwith( "Variable identifier" ^ name ^" unbounded")
        end
    | EPrim1(op, e) ->
     let argis = (compile_expr e si env) in
     begin match op with 
        | Add1 -> argis@ (check_num) @[IAdd(Reg(EAX), Const(2)); check_overflow]
        | Sub1 ->  argis @ check_num  @[ISub(Reg(EAX), Const(2)); check_overflow]
        | IsNum -> let l_isNum = gen_temp "l_isNum" in
                argis@[IAnd (Reg(EAX), Sized(DWORD_PTR, HexConst(0x1)));
                       ICmp(Reg(EAX), Sized(DWORD_PTR, HexConst(0x0)));
                       IJe(l_isNum); IMov(Reg(EAX), const_false); IRet;
                       ILabel(l_isNum);IMov(Reg(EAX), const_true);]
        | IsBool-> let isBool = gen_temp "isBool" in 
                argis@[IAnd(Reg(EAX), Sized(DWORD_PTR, HexConst(0x1)));
                       ICmp(Reg(EAX), Sized(DWORD_PTR, HexConst(0x0)));
                       IJne(isBool); IMov(Reg(EAX), const_false); IRet;
                       ILabel(isBool); IMov(Reg(EAX), const_true);]
     end
    | EPrim2(op, el, er) ->
      let arg1 = (compile_expr el (si) env) in
        let arg2 = (compile_expr er (si) env) in
         let l_pass = gen_temp "l_pass" in
         let l_finished = gen_temp "l_finished" in
           begin match op with
            | Plus ->   arg1@check_num@[IMov(RegOffset((si+1), ESP ), Reg(EAX))]@
                  arg2@check_num@[IMov(RegOffset((si+2), ESP), Reg(EAX))]
                  @[IMov(Reg(EAX), (RegOffset((si+1), ESP)))]
                  @[IAdd (Reg(EAX), (RegOffset((si+2), ESP ))); check_overflow]
            | Minus ->  arg1@check_num@[IMov(RegOffset((si+1), ESP ), Reg(EAX))]@
                  arg2@check_num@[IMov(RegOffset((si+2), ESP), Reg(EAX))]
                  @[IMov(Reg(EAX), (RegOffset((si+1), ESP)))]
                  @[ISub (Reg(EAX), (RegOffset((si+2), ESP ))); check_overflow]
            | Times ->  arg1@check_num@[IMov(RegOffset((si+1), ESP ), Reg(EAX))]@
                  arg2@check_num@[IMov(RegOffset((si+2), ESP), Reg(EAX))]
                  @[IMov(Reg(EAX), (RegOffset((si+1), ESP)))]
                  @[IMul (Reg(EAX), (RegOffset((si+2), ESP ))); check_overflow]
                  @[IShr(Reg(EAX), Const(1))] 
            | Less -> arg1@check_num@[IMov(RegOffset((si+1), ESP ), Reg(EAX))]@
                  arg2@check_num@[IMov(RegOffset((si+2), ESP), Reg(EAX))]
                  @[IMov(Reg(EAX), (RegOffset((si+1), ESP)));
                    ICmp (Reg(EAX), (RegOffset((si+2), ESP ))); IJl(l_pass);
                    IMov(Reg(EAX), const_false); IJmp(l_finished);
                    ILabel(l_pass); IMov(Reg(EAX), const_true);
                    ILabel(l_finished);] 
            | Greater -> arg1@check_num@[IMov(RegOffset((si+1), ESP ), Reg(EAX))]@
                  arg2@check_num@[IMov(RegOffset((si+2), ESP), Reg(EAX))]
                  @[IMov(Reg(EAX), (RegOffset((si+1), ESP)));
                    ICmp (Reg(EAX), (RegOffset((si+2), ESP ))); IJg(l_pass);
                    IMov(Reg(EAX), const_false); IJmp(l_finished);
                    ILabel(l_pass); IMov(Reg(EAX), const_true);
                    ILabel(l_finished);] 
            | Equal ->  arg1@check_num@[IMov(RegOffset((si+1), ESP ), Reg(EAX))]@
                  arg2@check_num@[IMov(RegOffset((si+2), ESP), Reg(EAX))]
                  @[IMov(Reg(EAX), (RegOffset((si+1), ESP)));
                    ICmp (Reg(EAX), (RegOffset((si+2), ESP ))); IJe(l_pass);
                    IMov(Reg(EAX), const_false); IJmp(l_finished);
                    ILabel(l_pass); IMov(Reg(EAX), const_true);
                    ILabel(l_finished);] 
         end
    | EIf(cond, thn, els) ->
      let l_then = gen_temp "then" in
      let l_else = gen_temp "else" in
      let l_end = gen_temp "end" in
      let e_cond = (compile_expr cond si env) in
      let e_then = (compile_expr thn si env) in
      let e_else = (compile_expr els si env) in
      e_cond @ [ ICmp(Reg(EAX), const_true); IJe(l_then);
                 ICmp(Reg(EAX), const_false); IJe(l_else);
                 IJmp((error_non_bool)); 
                 ILabel(l_then)
                  ] @       
      e_then @ [ IJmp((l_end)); ILabel(l_else) ] @
      e_else @ [ ILabel(l_end) ]
    | ELet([], body) -> compile_expr body si env
    | ELet((x, ex)::binds, body) ->
        let valis = compile_expr ex (si + 1) env in
            let bodyis = compile_expr body (si+1) ((x,si)::env) in
            valis @ [IMov(RegOffset(si,ESP), Reg(EAX))]@bodyis
let compile_to_string prog =
  let static_errors = check prog in
  let prelude = "section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: \n" in
  let postlude = [IRet]
    @ [ILabel(error_overflow)] @ (throw_err 3)
    @ [ILabel(error_non_int) ] @ (throw_err 1)
    @ [ILabel(error_non_bool)] @ (throw_err 2) in
  let compiled = compile_expr prog 1 [] in
  let as_assembly_string = to_asm (compiled @ postlude) in
  sprintf "%s%s\n" prelude as_assembly_string
