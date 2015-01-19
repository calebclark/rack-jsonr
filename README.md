rack-jsonr
===========

A Rack middleware for delivering JSONR (JSON as a Resource). With JSONR you can use get, post, put, and delete verbs, as
 well as access the http status, response headers, and the json body, even if there are errors.

## Setting Up JSONR

Install the gem:

  gem install rack-jsonr

In your Gemfile:

  gem 'rack-jsonr', :require => 'rack/jsonr'

You activate JSONR by including it your config.ru file:

 ```
 use Rack::JSONR
 run Sinatra::Application
 ```

## Benefits of JSONR

There are several benefits to using JSONR over JSONP...

### Ability to Use POST, PUT and DELETE Verbs

You can now make POST, PUT and DELETE requests through JSONR calls by including request_method=VERB in your query:

```
http://example.com/request?first_name=Caleb&request_method=PUT&callback=_jqjsp
```

That's it. Rails and Sinatra routes will now recognize it as a PUT request.

### Access to HTTP Status and Headers

With JSONR, the returned "http status" is always forced at 200 to ensure the browser always processes the
response. The real http status is included along with response headers as additional arguments in the
callback. This removes much of the limitations of JSONP.

### Access to Rich Error Data from the Client

One big frustration of standard JSONP is that when there is an error (http status greater than 200) there is no way to
access the returned JSON. This makes it difficult to handle form errors, for example.

With JSONR errors, the "http status" is forced at 200, which means you still have access to the response body,
http status, and headers.

## Using JSONR Responses through Existing Libraries

You can use jQuery or any other libraries that support JSONP with two caveats:

1. All callbacks will be returns as "success", even if there are errors, since the http status is always returned as 200.
 Therefore, you'll will need to parse the body of the response to determine if there are errors.

2. By default you won't have access to the http status and headers returned by JSONR since libraries like jQuery and
 jQuery-JSONP only read the first arg in the server callback.

However, there is hope...

## Using JSONR with jQuery-JSONP

I'm experimenting with a forked version of jQuery-JSONP, which extends the library to read JSONR while still being
backwards compatible with JSONP. It only changes two public methods:

#### 1. Two optional arguments were appended to the success callback:

##### success - `function` (`undefined`)

A function to be called if the request succeeds. The function gets passed three arguments: The JSON object returned from the server, a string describing the status (always `"success"`) and, *_as of version 2.4.0_* the `xOptions` object.

```js
function (json, textStatus, xOptions, httpStatus, httpHeaders) {
  this; // the xOptions object or xOptions.context if provided
}
```

#### 2. Three optional arguments were appended to the error callback:

##### error - `function` (`undefined`)

A function to be called if the request fails. The function is passed two arguments: The `xOptions` object and a string describing the type of error that occurred. Possible values for the second argument are `"error"` (the request finished but the JSONR callback was not called) or `"timeout"`.

```js
function (xOptions, textStatus, json, httpStatus, httpHeaders) {
  this; // the xOptions object or xOptions.context if provided
}
```

## What's Next?

We need to add tests.

## License

Please refer to [LICENSE.md](https://github.com/calebclark/rack-jsonr/blob/master/LICENSE.md).