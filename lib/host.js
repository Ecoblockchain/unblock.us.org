/*** Generated by streamline 0.10.12 (callbacks) - DO NOT EDIT ***/ var __rt=require('streamline/lib/callbacks/runtime').runtime(__filename, false),__func=__rt.__func,__cb=__rt.__cb; (function() {
  var a, contentTypes, crypto, isAltered, rDomains, redirectAllURLs, redirectToHash, settings;

  crypto = require("crypto");

  settings = require("../settings");

  redirectToHash = function redirectToHash__1(redisClient, res, host, path, clientIP, _) { var hash, keys, redirect, values; var __frame = { name: "redirectToHash__1", line: 8 }; return __func(_, this, arguments, redirectToHash__1, 5, __frame, function __$redirectToHash__1() {

      return (crypto.pseudoRandomBytes(16, __cb(_, __frame, 2, 19, function ___(__0, __2) { hash = __2.toString("hex");
        keys = [("hostTunneling-" + hash),("xforwardedfor-" + hash),];
        values = [host,clientIP,];
        return keys.forEach_(__cb(_, __frame, 5, 9, function __$redirectToHash__1() {



          redirect = (((("https://" + hash) + ".") + settings.hostTunnelingDomain) + path);
          res.writeHead(302, {
            Location: redirect });

          return _(null, res.end((((("<html><body>The unblock.us.org project<br /><br />Unblocked at <a href=\"" + redirect) + "\">") + redirect) + "</a></body></html>"))); }, true), -1, function __1(_, k, i) { var __frame = { name: "__1", line: 13 }; return __func(_, this, arguments, __1, 0, __frame, function __$__1() { return redisClient.set([k,values[i],], __cb(_, __frame, 1, 18, function __$__1() { return redisClient.expire([k,settings.hostTunnelingCaching,], __cb(_, __frame, 2, 25, _, true)); }, true)); }); }); }, true))); }); };


  contentTypes = {
  "application/javascript": "application/javascript",
  "application/xhtml+xml": "application/xhtml+xml",
  "application/xml": "application/xml",
  "image/svg+xml": "image/svg+xml",
  "text/css": "text/css",
  "text/html": "text/html",
  "text/javascript": "text/javascript" };


  isAltered = function(ct) {
    return (contentTypes[ct] != null); };


  rDomains = new RegExp(((function() {
    var _results;
    _results = [];
    for (a in settings.hijacked) {
      _results.push((("(" + a.replace(/[.]/g, "[.]")) + ")")); };

    return _results;
  })()).join("|"), "g");

  redirectAllURLs = function(str) {
    return str.replace(rDomains, function(e) {
      return (e + ".unblock"); }); };



  module.exports = {
    redirectToHash: redirectToHash,
    isAltered: isAltered,
    redirectAllURLs: redirectAllURLs };


}).call(this);