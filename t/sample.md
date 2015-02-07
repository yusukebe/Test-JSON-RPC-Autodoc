
## METHOD `POST`

### Request `echo-method`

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


## METHOD `POST`

### Request ``

```json
{
   "params" : {
      "language" : "日本語"
   },
   "jsonrpc" : "2.0",
   "method" : "echo",
   "id" : 1
}
```

### Parameters

* language - あなたの言語は？
  * `default`: **English**
  * `isa`: **Str**
  * `required`: **1**

### Response

```json
{
   "jsonrpc" : "2.0",
   "id" : 1,
   "result" : {
      "language" : "日本語"
   }
}
```


## METHOD `POST`

### Request ``

```json
{
   "params" : {},
   "jsonrpc" : "2.0",
   "method" : "echo",
   "id" : 1
}
```

### Parameters


### Response

```json
{
   "jsonrpc" : "2.0",
   "id" : 1,
   "result" : {}
}
```


