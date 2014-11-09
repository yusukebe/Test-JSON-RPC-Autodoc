
## METHOD `echo`

### Request

```json
{
   "params" : {
      "country" : "Japan",
      "language" : "Perl"
   },
   "jsonrpc" : "2.0",
   "method" : "echo",
   "id" : 1
}
```

### Parameters

* country - Your country
  * `isa`: **Str**
* language - Your language
  * `default`: **English**
  * `isa`: **Str**
  * `required`: **1**

### Response

```json
{
   "jsonrpc" : "2.0",
   "id" : 1,
   "result" : {
      "country" : "Japan",
      "language" : "Perl"
   }
}
```


