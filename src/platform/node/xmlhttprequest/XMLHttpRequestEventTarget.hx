package xmlhttprequest;

extern class XMLHttpRequestEventTarget {
	var onloadstart : haxe.Constraints.Function;
	var onprogress : haxe.Constraints.Function;
	var onabort : haxe.Constraints.Function;
	var onerror : haxe.Constraints.Function;
	var onload : haxe.Constraints.Function;
	var ontimeout : haxe.Constraints.Function;
	var onloadend : haxe.Constraints.Function;	
}