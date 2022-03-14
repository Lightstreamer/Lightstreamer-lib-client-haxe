package xmlhttprequest;

import haxe.extern.EitherType;

/**
	Use `XMLHttpRequest` (XHR) objects to interact with servers. You can retrieve data from a URL without having to do a full page refresh. This enables a Web page to update just part of a page without disrupting what the user is doing.

	Documentation [XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) by [Mozilla Contributors](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest$history), licensed under [CC-BY-SA 2.5](https://creativecommons.org/licenses/by-sa/2.5/).

	@see <https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest>
**/
@:jsRequire("xmlhttprequest", "XMLHttpRequest")
extern class XMLHttpRequest extends XMLHttpRequestEventTarget {
	static inline var UNSENT : Int = 0;
	static inline var OPENED : Int = 1;
	static inline var HEADERS_RECEIVED : Int = 2;
	static inline var LOADING : Int = 3;
	static inline var DONE : Int = 4;
	
	/**
		An `EventHandler` that is called whenever the `readyState` attribute changes.
	**/
	var onreadystatechange : haxe.Constraints.Function;
	
	/**
		Returns an `unsigned short`, the state of the request.
	**/
	var readyState(default,null) : Int;
	
	/**
		Is an `unsigned long` representing the number of milliseconds a request can take before automatically being terminated.
	**/
	var timeout : Int;
	
	/**
		Is a `Boolean` that indicates whether or not cross-site `Access-Control` requests should be made using credentials such as cookies or authorization headers.
	**/
	var withCredentials : Bool;
	
	/**
		Returns the serialized URL of the response or the empty string if the URL is null.
	**/
	var responseURL(default,null) : String;
	
	/**
		Returns an `unsigned short` with the status of the response of the request.
	**/
	var status(default,null) : Int;
	
	/**
		Returns a `DOMString` containing the response string returned by the HTTP server. Unlike `XMLHTTPRequest.status`, this includes the entire text of the response message ("`200 OK`", for example).
	**/
	var statusText(default,null) : String;
	
	/**
		Returns an `ArrayBuffer`, `Blob`, `Document`, JavaScript object, or a `DOMString`, depending on the value of `XMLHttpRequest.responseType`. that contains the response entity body.
	**/
	var response(default,null) : Dynamic;
	
	/**
		Returns a `DOMString` that contains the response to the request as text, or `null` if the request was unsuccessful or has not yet been sent.
	**/
	var responseText(default,null) : String;
	
	/** @throws DOMError */
	@:overload( function( ?params : Dynamic/*MISSING MozXMLHttpRequestParameters*/ ) : Void {} )
	function new( ignored : String ) : Void;
	
	/**
		Initializes a request. This method is to be used from JavaScript code; to initialize a request from native code, use `openRequest()` instead.
		@throws DOMError
	**/
	@:overload( function( method : String, url : String ) : Void {} )
	function open( method : String, url : String, async : Bool, ?user : String, ?password : String ) : Void;
	
	/**
		Sets the value of an HTTP request header. You must call `setRequestHeader()`after `open()`, but before `send()`.
		@throws DOMError
	**/
	function setRequestHeader( header : String, value : String ) : Void;
	
	/**
		Sends the request. If the request is asynchronous (which is the default), this method returns as soon as the request is sent.
		@throws DOMError
	**/
	function send( ?body : String ) : Void;
	
	/**
		Aborts the request if it has already been sent.
		@throws DOMError
	**/
	function abort() : Void;
	
	/**
		Returns the string containing the text of the specified header, or `null` if either the response has not yet been received or the header doesn't exist in the response.
		@throws DOMError
	**/
	function getResponseHeader( header : String ) : EitherType<String, Array<String>>;
	
	/**
		Returns all the response headers, separated by CRLF, as a string, or `null` if no response has been received.
		@throws DOMError
	**/
	function getAllResponseHeaders() : String;
	
	/**
		Overrides the MIME type returned by the server.
		@throws DOMError
	**/
	function overrideMimeType( mime : String ) : Void;

	/**
   * Disables or enables isAllowedHttpHeader() check the request. Enabled by default.
   * This does not conform to the W3C spec.
   *
   * @param boolean state Enable or disable header checking.
   */
	 function setDisableHeaderCheck(state: Bool) : Void;
}