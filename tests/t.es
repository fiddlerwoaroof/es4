package a.b {
public var c = 20
}
//var a = { b : { c : 10 } }
import a.b.c
intrinsic::print(a.b.c)
