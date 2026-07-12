--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Char (digitToInt, isAlphaNum, toLower)
import Data.List (find, foldl', intercalate, isSuffixOf)
import Data.Maybe (fromMaybe)
import Data.Monoid (mappend)
import qualified Data.Text as T
import Hakyll
import System.FilePath.Posix  ((</>))
import System.Process (proc, readCreateProcess)
import Text.HTML.TagSoup (Tag (..), parseTags)
import qualified Text.HTML.TagSoup as TagSoup
import Text.Pandoc (runPure, readTypst, writeHtml5String)
import Text.Pandoc.Definition (Block (Header), Pandoc)
import Text.Pandoc.Options (HTMLMathMethod (MathML), WriterOptions (..))
import Text.Pandoc.Walk (walk)

--------------------------------------------------------------------------------
root :: String
root = "https://ldgrp.me"

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Leo Orpilla III"
    , feedDescription = "Posts by Leo Orpilla III"
    , feedAuthorName  = "Leo Orpilla III"
    , feedAuthorEmail = "leo@ldgrp.me"
    , feedRoot        = root
    }

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "fonts/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "scripts/*" $ do
        route   idRoute
        compile copyFileCompiler

    tailwindDeps <- makePatternDependency $
        "templates/*" .||. "posts/**" .||. "ideas/**" .||. "recipes/**"
            .||. "index.md" .||. "404.html"
    rulesExtraDependencies [tailwindDeps] $
        match "css/input.css" $ do
            route   $ constRoute "css/style.css"
            compile tailwindCompiler

    match "css/syntax.css" $ do
        route   idRoute
        compile compressCssCompiler

    match "404.html" $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" siteCtx
            >>= relativizeUrls
    
    match "ideas/external/*.md" $ do
        route   $ metadataRoute urlRoute
        compile pandocCompiler

    match "ideas/*.md" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
                >>= fixHeadingIds
                >>= loadAndApplyTemplate "templates/post.html"    (tocField `mappend` ideaCtx)
                >>= loadAndApplyTemplate "templates/default.html" ideaCtx
                >>= relativizeUrls

    match "posts/external/*.md" $ do
        route   $ metadataRoute urlRoute
        compile pandocCompiler

    match "posts/*.md" $ do
        route removeDateRoute
        compile $ pandocCompiler
                >>= fixHeadingIds
                >>= loadAndApplyTemplate "templates/post.html"    (tocField `mappend` postCtx)
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    match "posts/*.typ" $ do
        route removeDateRoute
        compile $ typstCompiler
                >>= fixHeadingIds
                >>= loadAndApplyTemplate "templates/post.html"    (tocField `mappend` postCtx)
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    match "recipes/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
                >>= fixHeadingIds
                >>= loadAndApplyTemplate "templates/post.html"    (tocField `mappend` recipeCtx)
                >>= loadAndApplyTemplate "templates/default.html" recipeCtx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["ideas.html"] $ do
        route idRoute
        compile $ makeItem ""
                >>= loadAndApplyTemplate "templates/ideas.html"   ideasCtx
                >>= loadAndApplyTemplate "templates/default.html" ideasCtx
                >>= relativizeUrls


    match "index.md" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    create ["sitemap.xml"] $ do
        route idRoute
        compile $ do
            ps <- loadAll "posts/*.md"
            ts <- loadAll "posts/*.typ"
            is <- loadAll "ideas/*.md"
            rs <- loadAll "recipes/*"
            sp <- loadAll (fromList ["archive.html", "ideas.html"])
            let pages = ps ++ ts ++ is ++ rs ++ sp
                sitemapCtx =
                    constField "root" root `mappend`
                    listField "entries" siteCtx (return pages) `mappend`
                    defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = bodyField "description" `mappend` postCtx
            feedPosts <- fmap (take 20) . recentFirst =<< do
                a <- loadAllSnapshots "posts/*.md" "content"
                b <- loadAllSnapshots "posts/*.typ" "content"
                pure (a ++ b)
            renderAtom feedConfiguration feedCtx feedPosts

    match "robots.txt" $ do
        route idRoute
        compile copyFileCompiler

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
tailwindCompiler :: Compiler (Item String)
tailwindCompiler = do
    inputPath <- toFilePath <$> getUnderlying
    out <- unsafeCompiler $
        readCreateProcess
            (proc "tailwindcss" ["-i", inputPath, "-o", "-", "--minify"]) ""
    makeItem out

--------------------------------------------------------------------------------
-- | Compile a Typst source file to an HTML body with pandoc's typst reader.
typstCompiler :: Compiler (Item String)
typstCompiler = do
    item <- getResourceBody
    case runPure (readTypst defaultHakyllReaderOptions (T.pack (itemBody item))
                    >>= writeHtml5String typstWriterOptions . shiftHeadings) of
        Left  err -> fail ("Typst read error: " ++ show err)
        Right out -> return (itemSetBody (T.unpack out) item)

shiftHeadings :: Pandoc -> Pandoc
shiftHeadings = walk shift
  where
    shift (Header n attr inl) = Header (n + 1) attr inl
    shift b                   = b

-- | Emit inline MathML so @$…$@ renders natively, as the native export did.
typstWriterOptions :: WriterOptions
typstWriterOptions =
    defaultHakyllWriterOptions { writerHTMLMathMethod = MathML }

--------------------------------------------------------------------------------
-- Table of contents
--
-- Pandoc gives body headings ids for free; Typst's HTML export doesn't.
data Heading = Heading
    { headingLevel :: Int
    , headingId    :: String
    , headingText  :: String
    }

-- | Rewrite the post body so every heading carries an id.
fixHeadingIds :: Item String -> Compiler (Item String)
fixHeadingIds = withItemBody (return . fst . extractHeadings)

-- | Render toc from the body's headings.
tocField :: Context String
tocField = field "toc" $ \item -> do
    let headings = snd (extractHeadings (itemBody item))
        minLevel = minimum (maxBound : map headingLevel headings)
        ctx      = boolField "has-toc" (const (length headings >= 2)) `mappend`
                   listField "headings" (headingCtx minLevel) (mapM makeItem headings)
    tpl <- loadBody "templates/toc.html"
    itemBody <$> applyTemplate tpl ctx (itemSetBody () item)

headingCtx :: Int -> Context Heading
headingCtx minLevel =
    field "heading-id"    (return . headingId . itemBody) `mappend`
    field "heading-text"  (return . escapeHtml . headingText . itemBody) `mappend`
    field "heading-depth" (return . depth . itemBody)
  where
    -- Emit the heading's nesting depth (1, 2, 3, …) as plain data; the TOC
    -- template feeds it to a CSS custom property and CSS does the indenting,
    -- so no per-level utility classes have to survive Tailwind tree-shaking.
    depth h = show (min 3 (headingLevel h - minLevel + 1))

extractHeadings :: String -> (String, [Heading])
extractHeadings html = (TagSoup.renderTags tags, headings)
  where
    (tags, headings) = go [] (parseTags html)

    go :: [String] -> [Tag String] -> ([Tag String], [Heading])
    go used (TagOpen name attrs : rest)
        | Just level <- tagLevel name =
            let (inner, rest') = break (== TagClose name) rest
                (close, after) = splitAt 1 rest'
                text      = TagSoup.innerText inner
                hid       = fromMaybe (uniqueSlug used text) (lookup "id" attrs)
                attrs'    = ("id", hid) : filter ((/= "id") . fst) attrs
                (out, hs) = go (hid : used) after
            in ( TagOpen name attrs' : inner ++ close ++ out
               , Heading level hid text : hs )
    go used (t : rest) = let (out, hs) = go used rest in (t : out, hs)
    go _    []         = ([], [])

    tagLevel ['h', d] | d `elem` ['1' .. '4'] = Just (digitToInt d)
    tagLevel _                                = Nothing

-- | A URL-safe id for a heading: its text slugified, then suffixed
-- if that slug is already taken.
uniqueSlug :: [String] -> String -> String
uniqueSlug used text = fromMaybe slug (find (`notElem` used) candidates)
  where
    slug       = intercalate "-" (words (filter ok (map toLower text)))
    candidates = slug : [ slug ++ "-" ++ show n | n <- [1 :: Int ..] ]
    ok c       = isAlphaNum c || c == ' ' || c == '-'

--------------------------------------------------------------------------------
-- | A content hash of the compiled stylesheets, used to bust the browser
-- cache.
cssCacheField :: Context a
cssCacheField = field "css-version" $ \_ -> do
    style  <- loadBody "css/input.css"
    syntax <- loadBody "css/syntax.css"
    return (shortHash (style ++ syntax))

shortHash :: String -> String
shortHash = show . foldl' step (5381 :: Integer)
  where step h c = (h * 33 + toInteger (fromEnum c)) `mod` 4294967296

siteCtx :: Context String
siteCtx =
    cssCacheField `mappend`
    constField "root" root `mappend`
    cleanUrlField `mappend`
    defaultContext

cleanUrlField :: Context a
cleanUrlField = field "url" $ \item -> do
    mroute <- getRoute (itemIdentifier item)
    case mroute of
        Nothing -> noResult "no route for item"
        Just r  -> pure (cleanIndex (toUrl r))
  where
    cleanIndex u
        | "/index.html" `isSuffixOf` u = take (length u - 10) u
        | otherwise = u

entryCtx :: String -> Context String
entryCtx entryType =
    cssCacheField `mappend`
    constField "entry-type" entryType `mappend`
    dateField "date" "%d %b %Y" `mappend`
    readingTimeField `mappend`
    defaultContext

readingTimeField :: Context String
readingTimeField = field "reading-time" $ \item -> do
    let wordCount = length (words (TagSoup.innerText (parseTags (itemBody item))))
        minutes   = max 1 (ceiling (fromIntegral wordCount / 220 :: Double)) :: Int
    return (show minutes)

postCtx :: Context String
postCtx = entryCtx "post"

ideaCtx :: Context String
ideaCtx = entryCtx "idea"

recipeCtx :: Context String
recipeCtx = entryCtx "recipe"

--------------------------------------------------------------------------------
posts = do
    x <- loadAll "posts/*.md"
    y <- loadAll "posts/external/*.md"
    z <- loadAll "posts/*.typ"
    pure (x ++ y ++ z)

ideas = do
    x <- loadAll "ideas/*.md"
    y <- loadAll "ideas/external/*.md"
    pure (x ++ y)
    
--------------------------------------------------------------------------------

archiveCtx :: Context String
archiveCtx =
    cssCacheField `mappend`
    listField "posts" postCtx (recentFirst =<< posts) `mappend`
    listField "ideas" ideaCtx (recentFirst =<< ideas) `mappend`
    constField "title" "Archive" `mappend`
    defaultContext
    
indexCtx :: Context String
indexCtx =
    cssCacheField `mappend`
    listField "posts" postCtx (recentFirst =<< posts) `mappend`
    listField "ideas" ideaCtx (recentFirst =<< ideas) `mappend`
    constField "title" "Leo Orpilla III" `mappend`
    defaultContext

ideasCtx :: Context String
ideasCtx =
    cssCacheField `mappend`
    listField "ideas" ideaCtx (recentFirst =<< ideas) `mappend`
    constField "title" "Ideas" `mappend`
    defaultContext

--------------------------------------------------------------------------------
removeDateRoute :: Routes
removeDateRoute = 
  composeRoutes (gsubRoute "[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ const "") (setExtension "html")

urlRoute :: Metadata -> Routes
urlRoute = constRoute . fromMaybe "\\#" . lookupString "url"