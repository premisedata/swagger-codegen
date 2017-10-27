{-
   Swagger Petstore

   This spec is mainly for testing Petstore server and contains fake endpoints, models. Please do not use this for any other purpose. Special characters: \" \\

   OpenAPI spec version: 2.0
   Swagger Petstore API version: 1.0.0
   Contact: apiteam@swagger.io
   Generated by Swagger Codegen (https://github.com/swagger-api/swagger-codegen.git)
-}

{-|
Module : SwaggerPetstore.Core
-}

{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-name-shadowing -fno-warn-unused-binds #-}

module SwaggerPetstore.Core where

import SwaggerPetstore.MimeTypes
import SwaggerPetstore.Logging

import qualified Control.Arrow as P (left)
import qualified Control.DeepSeq as NF
import qualified Data.Aeson as A
import qualified Data.ByteString as B
import qualified Data.ByteString.Base64.Lazy as BL64
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString.Lazy.Char8 as BCL
import qualified Data.CaseInsensitive as CI
import qualified Data.Data as P (Data, Typeable, TypeRep, typeRep)
import qualified Data.Foldable as P
import qualified Data.Ix as P
import qualified Data.Maybe as P
import qualified Data.Proxy as P (Proxy(..))
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Time as TI
import qualified Data.Time.ISO8601 as TI
import qualified GHC.Base as P (Alternative)
import qualified Lens.Micro as L
import qualified Network.HTTP.Client.MultipartFormData as NH
import qualified Network.HTTP.Types as NH
import qualified Prelude as P
import qualified Web.FormUrlEncoded as WH
import qualified Web.HttpApiData as WH
import qualified Text.Printf as T

import Control.Applicative ((<|>))
import Control.Applicative (Alternative)
import Data.Function ((&))
import Data.Foldable(foldlM)
import Data.Monoid ((<>))
import Data.Text (Text)
import Prelude (($), (.), (<$>), (<*>), Maybe(..), Bool(..), Char, String, fmap, mempty, pure, return, show, IO, Monad, Functor)

-- * SwaggerPetstoreConfig

-- | 
data SwaggerPetstoreConfig = SwaggerPetstoreConfig
  { configHost  :: BCL.ByteString -- ^ host supplied in the Request
  , configUserAgent :: Text -- ^ user-agent supplied in the Request
  , configLogExecWithContext :: LogExecWithContext -- ^ Run a block using a Logger instance
  , configLogContext :: LogContext -- ^ Configures the logger
  , configAuthMethods :: [AnyAuthMethod] -- ^ List of configured auth methods
  , configValidateAuthMethods :: Bool -- ^ throw exceptions if auth methods are not configured
  }

-- | display the config
instance P.Show SwaggerPetstoreConfig where
  show c =
    T.printf
      "{ configHost = %v, configUserAgent = %v, ..}"
      (show (configHost c))
      (show (configUserAgent c))

-- | constructs a default SwaggerPetstoreConfig
--
-- configHost:
--
-- @http://petstore.swagger.io:80/v2@
--
-- configUserAgent:
--
-- @"swagger-haskell-http-client/1.0.0"@
--
newConfig :: IO SwaggerPetstoreConfig
newConfig = do
    logCxt <- initLogContext
    return $ SwaggerPetstoreConfig
        { configHost = "http://petstore.swagger.io:80/v2"
        , configUserAgent = "swagger-haskell-http-client/1.0.0"
        , configLogExecWithContext = runDefaultLogExecWithContext
        , configLogContext = logCxt
        , configAuthMethods = []
        , configValidateAuthMethods = True
        }  

-- | updates config use AuthMethod on matching requests
addAuthMethod :: AuthMethod auth => SwaggerPetstoreConfig -> auth -> SwaggerPetstoreConfig
addAuthMethod config@SwaggerPetstoreConfig {configAuthMethods = as} a =
  config { configAuthMethods = AnyAuthMethod a : as}

-- | updates the config to use stdout logging
withStdoutLogging :: SwaggerPetstoreConfig -> IO SwaggerPetstoreConfig
withStdoutLogging p = do
    logCxt <- stdoutLoggingContext (configLogContext p)
    return $ p { configLogExecWithContext = stdoutLoggingExec, configLogContext = logCxt }

-- | updates the config to use stderr logging
withStderrLogging :: SwaggerPetstoreConfig -> IO SwaggerPetstoreConfig
withStderrLogging p = do
    logCxt <- stderrLoggingContext (configLogContext p)
    return $ p { configLogExecWithContext = stderrLoggingExec, configLogContext = logCxt }

-- | updates the config to disable logging
withNoLogging :: SwaggerPetstoreConfig -> SwaggerPetstoreConfig
withNoLogging p = p { configLogExecWithContext =  runNullLogExec}
 
-- * SwaggerPetstoreRequest

-- | Represents a request. The "req" type variable is the request type. The "res" type variable is the response type.
data SwaggerPetstoreRequest req contentType res = SwaggerPetstoreRequest
  { rMethod  :: NH.Method   -- ^ Method of SwaggerPetstoreRequest
  , rUrlPath :: [BCL.ByteString] -- ^ Endpoint of SwaggerPetstoreRequest
  , rParams   :: Params -- ^ params of SwaggerPetstoreRequest
  , rAuthTypes :: [P.TypeRep] -- ^ types of auth methods
  }
  deriving (P.Show)

-- | 'rMethod' Lens
rMethodL :: Lens_' (SwaggerPetstoreRequest req contentType res) NH.Method
rMethodL f SwaggerPetstoreRequest{..} = (\rMethod -> SwaggerPetstoreRequest { rMethod, ..} ) <$> f rMethod
{-# INLINE rMethodL #-}

-- | 'rUrlPath' Lens
rUrlPathL :: Lens_' (SwaggerPetstoreRequest req contentType res) [BCL.ByteString]
rUrlPathL f SwaggerPetstoreRequest{..} = (\rUrlPath -> SwaggerPetstoreRequest { rUrlPath, ..} ) <$> f rUrlPath
{-# INLINE rUrlPathL #-}

-- | 'rParams' Lens
rParamsL :: Lens_' (SwaggerPetstoreRequest req contentType res) Params
rParamsL f SwaggerPetstoreRequest{..} = (\rParams -> SwaggerPetstoreRequest { rParams, ..} ) <$> f rParams
{-# INLINE rParamsL #-}

-- | 'rParams' Lens
rAuthTypesL :: Lens_' (SwaggerPetstoreRequest req contentType res) [P.TypeRep]
rAuthTypesL f SwaggerPetstoreRequest{..} = (\rAuthTypes -> SwaggerPetstoreRequest { rAuthTypes, ..} ) <$> f rAuthTypes
{-# INLINE rAuthTypesL #-}

-- * HasBodyParam

-- | Designates the body parameter of a request
class HasBodyParam req param where
  setBodyParam :: forall contentType res. (Consumes req contentType, MimeRender contentType param) => SwaggerPetstoreRequest req contentType res -> param -> SwaggerPetstoreRequest req contentType res
  setBodyParam req xs =
    req `_setBodyLBS` mimeRender (P.Proxy :: P.Proxy contentType) xs & _setContentTypeHeader

-- * HasOptionalParam

-- | Designates the optional parameters of a request
class HasOptionalParam req param where
  {-# MINIMAL applyOptionalParam | (-&-) #-}

  -- | Apply an optional parameter to a request
  applyOptionalParam :: SwaggerPetstoreRequest req contentType res -> param -> SwaggerPetstoreRequest req contentType res
  applyOptionalParam = (-&-)
  {-# INLINE applyOptionalParam #-}

  -- | infix operator \/ alias for 'addOptionalParam'
  (-&-) :: SwaggerPetstoreRequest req contentType res -> param -> SwaggerPetstoreRequest req contentType res
  (-&-) = applyOptionalParam
  {-# INLINE (-&-) #-}

infixl 2 -&-

-- | Request Params
data Params = Params
  { paramsQuery :: NH.Query
  , paramsHeaders :: NH.RequestHeaders
  , paramsBody :: ParamBody
  }
  deriving (P.Show)

-- | 'paramsQuery' Lens
paramsQueryL :: Lens_' Params NH.Query
paramsQueryL f Params{..} = (\paramsQuery -> Params { paramsQuery, ..} ) <$> f paramsQuery
{-# INLINE paramsQueryL #-}

-- | 'paramsHeaders' Lens
paramsHeadersL :: Lens_' Params NH.RequestHeaders
paramsHeadersL f Params{..} = (\paramsHeaders -> Params { paramsHeaders, ..} ) <$> f paramsHeaders
{-# INLINE paramsHeadersL #-}

-- | 'paramsBody' Lens
paramsBodyL :: Lens_' Params ParamBody
paramsBodyL f Params{..} = (\paramsBody -> Params { paramsBody, ..} ) <$> f paramsBody
{-# INLINE paramsBodyL #-}

-- | Request Body
data ParamBody
  = ParamBodyNone
  | ParamBodyB B.ByteString
  | ParamBodyBL BL.ByteString
  | ParamBodyFormUrlEncoded WH.Form
  | ParamBodyMultipartFormData [NH.Part]
  deriving (P.Show)

-- ** SwaggerPetstoreRequest Utils

_mkRequest :: NH.Method -- ^ Method 
          -> [BCL.ByteString] -- ^ Endpoint
          -> SwaggerPetstoreRequest req contentType res -- ^ req: Request Type, res: Response Type
_mkRequest m u = SwaggerPetstoreRequest m u _mkParams []

_mkParams :: Params
_mkParams = Params [] [] ParamBodyNone

setHeader :: SwaggerPetstoreRequest req contentType res -> [NH.Header] -> SwaggerPetstoreRequest req contentType res
setHeader req header =
  req `removeHeader` P.fmap P.fst header &
  L.over (rParamsL . paramsHeadersL) (header P.++)

removeHeader :: SwaggerPetstoreRequest req contentType res -> [NH.HeaderName] -> SwaggerPetstoreRequest req contentType res
removeHeader req header =
  req &
  L.over
    (rParamsL . paramsHeadersL)
    (P.filter (\h -> cifst h `P.notElem` P.fmap CI.mk header))
  where
    cifst = CI.mk . P.fst


_setContentTypeHeader :: forall req contentType res. MimeType contentType => SwaggerPetstoreRequest req contentType res -> SwaggerPetstoreRequest req contentType res
_setContentTypeHeader req =
    case mimeType (P.Proxy :: P.Proxy contentType) of 
        Just m -> req `setHeader` [("content-type", BC.pack $ P.show m)]
        Nothing -> req `removeHeader` ["content-type"]

_setAcceptHeader :: forall req contentType res accept. MimeType accept => SwaggerPetstoreRequest req contentType res -> accept -> SwaggerPetstoreRequest req contentType res
_setAcceptHeader req accept =
    case mimeType' accept of 
        Just m -> req `setHeader` [("accept", BC.pack $ P.show m)]
        Nothing -> req `removeHeader` ["accept"]

setQuery :: SwaggerPetstoreRequest req contentType res -> [NH.QueryItem] -> SwaggerPetstoreRequest req contentType res
setQuery req query = 
  req &
  L.over
    (rParamsL . paramsQueryL)
    ((query P.++) . P.filter (\q -> cifst q `P.notElem` P.fmap cifst query))
  where
    cifst = CI.mk . P.fst

addForm :: SwaggerPetstoreRequest req contentType res -> WH.Form -> SwaggerPetstoreRequest req contentType res
addForm req newform = 
    let form = case paramsBody (rParams req) of
            ParamBodyFormUrlEncoded _form -> _form
            _ -> mempty
    in req & L.set (rParamsL . paramsBodyL) (ParamBodyFormUrlEncoded (newform <> form))

_addMultiFormPart :: SwaggerPetstoreRequest req contentType res -> NH.Part -> SwaggerPetstoreRequest req contentType res
_addMultiFormPart req newpart = 
    let parts = case paramsBody (rParams req) of
            ParamBodyMultipartFormData _parts -> _parts
            _ -> []
    in req & L.set (rParamsL . paramsBodyL) (ParamBodyMultipartFormData (newpart : parts))

_setBodyBS :: SwaggerPetstoreRequest req contentType res -> B.ByteString -> SwaggerPetstoreRequest req contentType res
_setBodyBS req body = 
    req & L.set (rParamsL . paramsBodyL) (ParamBodyB body)

_setBodyLBS :: SwaggerPetstoreRequest req contentType res -> BL.ByteString -> SwaggerPetstoreRequest req contentType res
_setBodyLBS req body = 
    req & L.set (rParamsL . paramsBodyL) (ParamBodyBL body)

_hasAuthType :: AuthMethod authMethod => SwaggerPetstoreRequest req contentType res -> P.Proxy authMethod -> SwaggerPetstoreRequest req contentType res
_hasAuthType req proxy =
  req & L.over rAuthTypesL (P.typeRep proxy :)

-- ** Params Utils

toPath
  :: WH.ToHttpApiData a
  => a -> BCL.ByteString
toPath = BB.toLazyByteString . WH.toEncodedUrlPiece

toHeader :: WH.ToHttpApiData a => (NH.HeaderName, a) -> [NH.Header]
toHeader x = [fmap WH.toHeader x]

toForm :: WH.ToHttpApiData v => (BC.ByteString, v) -> WH.Form
toForm (k,v) = WH.toForm [(BC.unpack k,v)]

toQuery :: WH.ToHttpApiData a => (BC.ByteString, Maybe a) -> [NH.QueryItem]
toQuery x = [(fmap . fmap) toQueryParam x]
  where toQueryParam = T.encodeUtf8 . WH.toQueryParam

-- *** Swagger `CollectionFormat` Utils

-- | Determines the format of the array if type array is used.
data CollectionFormat
  = CommaSeparated -- ^ CSV format for multiple parameters.
  | SpaceSeparated -- ^ Also called "SSV"
  | TabSeparated -- ^ Also called "TSV"
  | PipeSeparated -- ^ `value1|value2|value2`
  | MultiParamArray -- ^ Using multiple GET parameters, e.g. `foo=bar&foo=baz`. This is valid only for parameters in "query" ('NH.Query') or "formData" ('WH.Form')

toHeaderColl :: WH.ToHttpApiData a => CollectionFormat -> (NH.HeaderName, [a]) -> [NH.Header]
toHeaderColl c xs = _toColl c toHeader xs

toFormColl :: WH.ToHttpApiData v => CollectionFormat -> (BC.ByteString, [v]) -> WH.Form
toFormColl c xs = WH.toForm $ fmap unpack $ _toColl c toHeader $ pack xs
  where
    pack (k,v) = (CI.mk k, v)
    unpack (k,v) = (BC.unpack (CI.original k), BC.unpack v)

toQueryColl :: WH.ToHttpApiData a => CollectionFormat -> (BC.ByteString, Maybe [a]) -> NH.Query
toQueryColl c xs = _toCollA c toQuery xs

_toColl :: P.Traversable f => CollectionFormat -> (f a -> [(b, BC.ByteString)]) -> f [a] -> [(b, BC.ByteString)]
_toColl c encode xs = fmap (fmap P.fromJust) (_toCollA' c fencode BC.singleton (fmap Just xs))
  where fencode = fmap (fmap Just) . encode . fmap P.fromJust
        {-# INLINE fencode #-}

_toCollA :: (P.Traversable f, P.Traversable t, P.Alternative t) => CollectionFormat -> (f (t a) -> [(b, t BC.ByteString)]) -> f (t [a]) -> [(b, t BC.ByteString)]
_toCollA c encode xs = _toCollA' c encode BC.singleton xs

_toCollA' :: (P.Monoid c, P.Traversable f, P.Traversable t, P.Alternative t) => CollectionFormat -> (f (t a) -> [(b, t c)]) -> (Char -> c) -> f (t [a]) -> [(b, t c)]
_toCollA' c encode one xs = case c of
  CommaSeparated -> go (one ',')
  SpaceSeparated -> go (one ' ')
  TabSeparated -> go (one '\t')
  PipeSeparated -> go (one '|')
  MultiParamArray -> expandList
  where
    go sep =
      [P.foldl1 (\(sk, sv) (_, v) -> (sk, (combine sep <$> sv <*> v) <|> sv <|> v)) expandList]
    combine sep x y = x <> sep <> y
    expandList = (P.concatMap encode . (P.traverse . P.traverse) P.toList) xs
    {-# INLINE go #-}
    {-# INLINE expandList #-}
    {-# INLINE combine #-}
  
-- * AuthMethods

-- | Provides a method to apply auth methods to requests
class P.Typeable a =>
      AuthMethod a  where
  applyAuthMethod
    :: SwaggerPetstoreConfig
    -> a
    -> SwaggerPetstoreRequest req contentType res
    -> IO (SwaggerPetstoreRequest req contentType res)

-- | An existential wrapper for any AuthMethod
data AnyAuthMethod = forall a. AuthMethod a => AnyAuthMethod a deriving (P.Typeable)

instance AuthMethod AnyAuthMethod where applyAuthMethod config (AnyAuthMethod a) req = applyAuthMethod config a req

-- | apply all matching AuthMethods in config to request
_applyAuthMethods
  :: SwaggerPetstoreRequest req contentType res
  -> SwaggerPetstoreConfig
  -> IO (SwaggerPetstoreRequest req contentType res)
_applyAuthMethods req config@(SwaggerPetstoreConfig {configAuthMethods = as}) =
  foldlM go req as
  where
    go r (AnyAuthMethod a) = applyAuthMethod config a r
  
-- * Utils

-- | Removes Null fields.  (OpenAPI-Specification 2.0 does not allow Null in JSON)
_omitNulls :: [(Text, A.Value)] -> A.Value
_omitNulls = A.object . P.filter notNull
  where
    notNull (_, A.Null) = False
    notNull _ = True

-- | Encodes fields using WH.toQueryParam
_toFormItem :: (WH.ToHttpApiData a, Functor f) => t -> f a -> f (t, [Text])
_toFormItem name x = (name,) . (:[]) . WH.toQueryParam <$> x

-- | Collapse (Just "") to Nothing
_emptyToNothing :: Maybe String -> Maybe String
_emptyToNothing (Just "") = Nothing
_emptyToNothing x = x
{-# INLINE _emptyToNothing #-}

-- | Collapse (Just mempty) to Nothing
_memptyToNothing :: (P.Monoid a, P.Eq a) => Maybe a -> Maybe a
_memptyToNothing (Just x) | x P.== P.mempty = Nothing
_memptyToNothing x = x
{-# INLINE _memptyToNothing #-}

-- * DateTime Formatting

newtype DateTime = DateTime { unDateTime :: TI.UTCTime }
  deriving (P.Eq,P.Data,P.Ord,P.Typeable,NF.NFData,TI.ParseTime,TI.FormatTime)
instance A.FromJSON DateTime where
  parseJSON = A.withText "DateTime" (_readDateTime . T.unpack)
instance A.ToJSON DateTime where
  toJSON (DateTime t) = A.toJSON (_showDateTime t)
instance WH.FromHttpApiData DateTime where
  parseUrlPiece = P.left T.pack . _readDateTime . T.unpack
instance WH.ToHttpApiData DateTime where
  toUrlPiece (DateTime t) = T.pack (_showDateTime t)
instance P.Show DateTime where
  show (DateTime t) = _showDateTime t
instance MimeRender MimeMultipartFormData DateTime where
  mimeRender _ = mimeRenderDefaultMultipartFormData

-- | @_parseISO8601@
_readDateTime :: (TI.ParseTime t, Monad m, Alternative m) => String -> m t
_readDateTime =
  _parseISO8601
{-# INLINE _readDateTime #-}

-- | @TI.formatISO8601Millis@
_showDateTime :: (t ~ TI.UTCTime, TI.FormatTime t) => t -> String
_showDateTime =
  TI.formatISO8601Millis
{-# INLINE _showDateTime #-}

-- | parse an ISO8601 date-time string
_parseISO8601 :: (TI.ParseTime t, Monad m, Alternative m) => String -> m t
_parseISO8601 t =
  P.asum $
  P.flip (TI.parseTimeM True TI.defaultTimeLocale) t <$>
  ["%FT%T%QZ", "%FT%T%Q%z", "%FT%T%Q%Z"]
{-# INLINE _parseISO8601 #-}

-- * Date Formatting

newtype Date = Date { unDate :: TI.Day }
  deriving (P.Enum,P.Eq,P.Data,P.Ord,P.Ix,NF.NFData,TI.ParseTime,TI.FormatTime)
instance A.FromJSON Date where
  parseJSON = A.withText "Date" (_readDate . T.unpack)
instance A.ToJSON Date where
  toJSON (Date t) = A.toJSON (_showDate t)
instance WH.FromHttpApiData Date where
  parseUrlPiece = P.left T.pack . _readDate . T.unpack
instance WH.ToHttpApiData Date where
  toUrlPiece (Date t) = T.pack (_showDate t)
instance P.Show Date where
  show (Date t) = _showDate t
instance MimeRender MimeMultipartFormData Date where
  mimeRender _ = mimeRenderDefaultMultipartFormData

-- | @TI.parseTimeM True TI.defaultTimeLocale "%Y-%m-%d"@
_readDate :: (TI.ParseTime t, Monad m) => String -> m t
_readDate =
  TI.parseTimeM True TI.defaultTimeLocale "%Y-%m-%d"
{-# INLINE _readDate #-}

-- | @TI.formatTime TI.defaultTimeLocale "%Y-%m-%d"@
_showDate :: TI.FormatTime t => t -> String
_showDate =
  TI.formatTime TI.defaultTimeLocale "%Y-%m-%d"
{-# INLINE _showDate #-}

-- * Byte/Binary Formatting

  
-- | base64 encoded characters
newtype ByteArray = ByteArray { unByteArray :: BL.ByteString }
  deriving (P.Eq,P.Data,P.Ord,P.Typeable,NF.NFData)

instance A.FromJSON ByteArray where
  parseJSON = A.withText "ByteArray" _readByteArray
instance A.ToJSON ByteArray where
  toJSON = A.toJSON . _showByteArray
instance WH.FromHttpApiData ByteArray where
  parseUrlPiece = P.left T.pack . _readByteArray
instance WH.ToHttpApiData ByteArray where
  toUrlPiece = _showByteArray
instance P.Show ByteArray where
  show = T.unpack . _showByteArray
instance MimeRender MimeMultipartFormData ByteArray where
  mimeRender _ = mimeRenderDefaultMultipartFormData

-- | read base64 encoded characters
_readByteArray :: Monad m => Text -> m ByteArray
_readByteArray = P.either P.fail (pure . ByteArray) . BL64.decode . BL.fromStrict . T.encodeUtf8
{-# INLINE _readByteArray #-}

-- | show base64 encoded characters
_showByteArray :: ByteArray -> Text
_showByteArray = T.decodeUtf8 . BL.toStrict . BL64.encode . unByteArray
{-# INLINE _showByteArray #-}

-- | any sequence of octets
newtype Binary = Binary { unBinary :: BL.ByteString }
  deriving (P.Eq,P.Data,P.Ord,P.Typeable,NF.NFData)

instance A.FromJSON Binary where
  parseJSON = A.withText "Binary" _readBinaryBase64
instance A.ToJSON Binary where
  toJSON = A.toJSON . _showBinaryBase64
instance WH.FromHttpApiData Binary where
  parseUrlPiece = P.left T.pack . _readBinaryBase64
instance WH.ToHttpApiData Binary where
  toUrlPiece = _showBinaryBase64
instance P.Show Binary where
  show = T.unpack . _showBinaryBase64
instance MimeRender MimeMultipartFormData Binary where
  mimeRender _ = unBinary

_readBinaryBase64 :: Monad m => Text -> m Binary
_readBinaryBase64 = P.either P.fail (pure . Binary) . BL64.decode . BL.fromStrict . T.encodeUtf8
{-# INLINE _readBinaryBase64 #-}

_showBinaryBase64 :: Binary -> Text
_showBinaryBase64 = T.decodeUtf8 . BL.toStrict . BL64.encode . unBinary
{-# INLINE _showBinaryBase64 #-}

-- * Lens Type Aliases

type Lens_' s a = Lens_ s s a a
type Lens_ s t a b = forall (f :: * -> *). Functor f => (a -> f b) -> s -> f t
