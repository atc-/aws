{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies #-}
module AWS.Transaction
where
  
import AWS.Query
import AWS.Response
import AWS.Credentials
import AWS.Http
import Text.XML.Monad

class (AsQuery request info, FromResponse response) 
    => Transaction request info response | request -> response, request -> info, response -> request

transact :: (Transaction request info response) 
            => (HttpRequest -> IO HttpResponse) -> TimeInfo -> Credentials -> info -> request -> IO (Either XmlError response)
transact http ti cr i r = do
  q <- signQuery ti cr $ asQuery i r
  let httpRequest = queryToRequest q
  httpResponse <- http httpRequest
  let rsp = Response httpResponse
  return $ runXml rsp fromResponse
  