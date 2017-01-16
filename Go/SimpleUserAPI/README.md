
# The simplest of Go API's

Requires postgres be running on port `5432`

# Register User

`POST /users`

### Request
> ```json
{
    "username": "vdka",
    "password": "somePass123"
}
```

### Response
> ```
HTTP/1.1 201 Created
Content-Length: 181
Content-Type: application/json; charset=utf-8
Date: Mon, 16 Jan 2017 02:01:37 GMT
```
>```json
{
    "createdAt": "2017-01-16T12:01:37.318770403+10:00",
    "deletedAt": null,
    "id": "a386fb91-c8d2-4f86-b95c-604ce8dff6bf",
    "updatedAt": "2017-01-16T12:01:37.318770403+10:00",
    "username": "vdka"
}
```

## Authorizing as User

`POST /auth`

### Request
> ```json
{
    "username": "vdka",
    "password": "somePass123"
}
```

### Response
> ```
HTTP/1.1 200 OK
Content-Length: 233
Content-Type: application/json; charset=utf-8
Date: Mon, 16 Jan 2017 02:06:20 GMT
```
> ```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODQ1MzQxODAsImp0aSI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCIsImlhdCI6MTQ4NDUzMjM4MCwiaXNzIjoiUmVnaW9uc0FQSSJ9.nIjFHVxWkA_HKSt4LpGOpZJZh6nIv7hfIBVk6W49a5Q"
}
```

## Retrieve User details

```
GET /user
access_token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODQ1MzQxODAsImp0aSI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCIsImlhdCI6MTQ4NDUzMjM4MCwiaXNzIjoiUmVnaW9uc0FQSSJ9.nIjFHVxWkA_HKSt4LpGOpZJZh6nIv7hfIBVk6W49a5Q
````

### Response
> ```json
{
    "createdAt": "2017-01-16T02:01:37.31877Z",
    "deletedAt": null,
    "id": "a386fb91-c8d2-4f86-b95c-604ce8dff6bf",
    "updatedAt": "2017-01-16T02:01:37.31877Z",
    "username": "vdka"
}
```

