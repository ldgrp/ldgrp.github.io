---
title: Factoring APIs in servant-client
---

I am currently writing a Haskell client 
[library][up-api] for the Up Bank API with 
[`servant-client`][servant-client].

Endpoints require an `Authentication` request header with the format 
`Authorization: TOKEN_TYPE Token`


With servant, we can represent this with the `Header` combinator and add it to 
every endpoint. For example, the type of an API is as follows.

```Haskell
type API = 
       Header "Authorization" String :> Capture "x" Int :> Get '[JSON] X
  :<|> Header "Authorization" String :> Capture "y" Int :> Get '[JSON] Y
```

We can factor out the `Header`s, similar to factoring in algebra `f g + f h = f (g + h)`

``` Haskell
type FactoredAPI =  Header "Authorization" String :>
  (    Capture "x" Int :> Get '[JSON] X
  :<|> Capture "y" Int :> Get '[JSON] Y
  )
```

## Clients

`servant-client` provides the function `client` which automagically generates 
implementations and allows us to pattern match on the client functions of the API. 

An implementation of the unfactored client API is as follows.

```Haskell
getX :: Maybe String  -- ^ token
     -> Int           -- ^ x
     -> ClientM X

getY :: Maybe String  -- ^ token
     -> Int           -- ^ y
     -> ClientM Y
             
api :: Proxy API
api = Proxy
             
getX :<|> getY = client api
```

Let's look at the type of the unfactored client API.
It returns two client functions combined with `:<|>`. 

```Haskell
ghci> :t client (Proxy :: Proxy API)
client (Proxy :: Proxy FactoredAPI)
  :: (Maybe [Char] -> Int -> ClientM X)
        :<|> (Maybe [Char] -> Int -> ClientM Y)
```


Whereas the client of the factored API returns a function that takes 
a token and returns two client functions.

```Haskell
ghci> :t client (Proxy :: Proxy FactoredAPI)
client (Proxy :: Proxy FactoredAPI)
  :: Maybe [Char]
     -> (Int -> ClientM X)
        :<|> (Int -> ClientM Y)
```


An implementation of the factored API is then
```Haskell
getX' :: Int  -- ^ x
      -> ClientM X

getY' :: Int  -- ^ y
      -> ClientM Y
             
api' :: Proxy FactoredAPI
api' = Proxy
             
getX' :<|> getY' = client api' token
  where token :: Maybe String
```

As expected, `client api' token` will return two client functions.

[servant-client]: https://hackage.haskell.org/package/servant-client 
[up-api]: https://github.com/ldgrp/up-api-haskell
